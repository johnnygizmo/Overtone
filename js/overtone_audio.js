// Spike S4: small Web Audio engine. Notes are scheduled on the audio clock.
// `create(ctx)` accepts an OfflineAudioContext so behaviour can be tested
// without speakers.
(function () {
  'use strict';

  // Additive "keys" voice: fundamental plus a few decaying partials.
  const PARTIALS = [[1, 1.0], [2, 0.42], [3, 0.2], [4, 0.1], [5, 0.05]];
  const PARTIAL_SUM = PARTIALS.reduce((s, p) => s + p[1], 0);
  const NOTE_PEAK = 0.22;

  function midiToFreq(m) {
    return 440 * Math.pow(2, (m - 69) / 12);
  }

  // Identity below the knee, smooth saturation above it; output stays < 1.
  function softClipCurve() {
    const n = 2048;
    const curve = new Float32Array(n);
    const knee = 0.7;
    for (let i = 0; i < n; i++) {
      const x = (i / (n - 1)) * 2 - 1;
      const a = Math.abs(x);
      curve[i] = a <= knee ? x : Math.sign(x) * (knee + (1 - knee) * Math.tanh((a - knee) / (1 - knee)));
    }
    return curve;
  }

  function create(initialCtx) {
    let ctx = initialCtx || null;
    let master = null;
    let nextId = 1;
    const groups = new Map();

    function ensure() {
      if (!ctx) {
        const AC = window.AudioContext || window.webkitAudioContext;
        ctx = new AC({ latencyHint: 'interactive' });
      }
      if (!master) {
        const gain = ctx.createGain();
        gain.gain.value = 0.8;
        const comp = ctx.createDynamicsCompressor();
        comp.threshold.value = -12;
        comp.knee.value = 6;
        comp.ratio.value = 12;
        comp.attack.value = 0.003;
        comp.release.value = 0.15;
        const clip = ctx.createWaveShaper();
        clip.curve = softClipCurve();
        gain.connect(comp);
        comp.connect(clip);
        clip.connect(ctx.destination);
        master = { gain, comp, clip };
      }
    }

    return {
      async unlock() {
        ensure();
        if (ctx.state === 'suspended') await ctx.resume();
        return ctx.state;
      },

      state() {
        return ctx ? ctx.state : 'not-created';
      },

      info() {
        ensure();
        return {
          state: ctx.state,
          sampleRate: ctx.sampleRate,
          baseLatency: ctx.baseLatency === undefined ? null : ctx.baseLatency,
          outputLatency: ctx.outputLatency === undefined ? null : ctx.outputLatency,
          currentTime: ctx.currentTime,
        };
      },

      now() {
        return ctx ? ctx.currentTime : 0;
      },

      setVolume(v) {
        ensure();
        master.gain.gain.setTargetAtTime(Math.max(0, Math.min(1, v)), ctx.currentTime, 0.01);
      },

      // notes: [{t, dur, midi, vel}] with t in seconds relative to the start.
      // opts: {at} absolute context time, or {delay} seconds from now.
      play(notes, opts) {
        ensure();
        const o = opts || {};
        const start = o.at !== undefined ? o.at : ctx.currentTime + (o.delay === undefined ? 0.05 : o.delay);
        const id = nextId++;
        const group = ctx.createGain();
        group.connect(master.gain);
        const oscs = [];
        let remaining = 0;
        const done = () => {
          if (--remaining === 0) {
            group.disconnect();
            groups.delete(id);
          }
        };

        for (const n of notes) {
          const t0 = start + n.t;
          const peak = NOTE_PEAK * (n.vel === undefined ? 0.8 : n.vel);
          const env = ctx.createGain();
          env.connect(group);
          env.gain.setValueAtTime(0, t0);
          env.gain.linearRampToValueAtTime(peak, t0 + 0.006);
          env.gain.setTargetAtTime(peak * 0.3, t0 + 0.006, 0.6);
          env.gain.setTargetAtTime(0, t0 + n.dur, 0.05);
          const stopAt = t0 + n.dur + 0.4;
          const f = midiToFreq(n.midi);
          for (const [k, amp] of PARTIALS) {
            if (f * k > 12000) continue;
            const osc = ctx.createOscillator();
            osc.type = 'sine';
            osc.frequency.value = f * k;
            const pg = ctx.createGain();
            pg.gain.value = amp / PARTIAL_SUM;
            osc.connect(pg);
            pg.connect(env);
            osc.start(t0);
            osc.stop(stopAt);
            osc.onended = done;
            remaining++;
            oscs.push(osc);
          }
        }
        groups.set(id, { group, oscs });
        return id;
      },

      // Fades the group out and stops it. {at, fadeMs}
      stop(id, opts) {
        const g = groups.get(id);
        if (!g) return;
        const o = opts || {};
        const at = o.at !== undefined ? o.at : ctx.currentTime;
        const fade = (o.fadeMs === undefined ? 15 : o.fadeMs) / 1000;
        g.group.gain.setTargetAtTime(0, at, fade / 4);
        for (const osc of g.oscs) {
          try {
            osc.stop(at + fade + 0.02);
          } catch (_) {
            /* already stopped */
          }
        }
      },

      stopAll(opts) {
        for (const id of Array.from(groups.keys())) this.stop(id, opts);
      },

      activeGroups() {
        return groups.size;
      },
    };
  }

  // ---- Offline self-test -------------------------------------------------

  async function render(seconds, sr, build) {
    const octx = new OfflineAudioContext(1, Math.ceil(seconds * sr), sr);
    const eng = create(octx);
    build(eng);
    const buf = await octx.startRendering();
    return buf.getChannelData(0);
  }

  function firstAbove(x, thr) {
    for (let i = 0; i < x.length; i++) if (Math.abs(x[i]) > thr) return i;
    return -1;
  }

  function goertzel(x, i0, i1, f, sr) {
    const w = (2 * Math.PI * f) / sr;
    const c = 2 * Math.cos(w);
    let s0 = 0, s1 = 0, s2 = 0;
    for (let i = i0; i < i1; i++) {
      s0 = x[i] + c * s1 - s2;
      s2 = s1;
      s1 = s0;
    }
    const power = s1 * s1 + s2 * s2 - c * s1 * s2;
    return Math.sqrt(Math.max(power, 0)) / (i1 - i0);
  }

  function peakFreq(x, sr, t0, t1, fLo, fHi, step) {
    const i0 = Math.floor(t0 * sr), i1 = Math.floor(t1 * sr);
    let best = fLo, bestMag = -1;
    for (let f = fLo; f <= fHi; f += step) {
      const m = goertzel(x, i0, i1, f, sr);
      if (m > bestMag) { bestMag = m; best = f; }
    }
    return best;
  }

  function peak(x) {
    let p = 0;
    for (let i = 0; i < x.length; i++) {
      const a = Math.abs(x[i]);
      if (a > p || Number.isNaN(a)) p = a;
    }
    return p;
  }

  function maxJump(x, i0, i1) {
    let j = 0;
    for (let i = Math.max(1, i0); i < i1; i++) j = Math.max(j, Math.abs(x[i] - x[i - 1]));
    return j;
  }

  async function selfTest() {
    const sr = 44100;
    const out = {};

    // 1. Onset lands where it was scheduled (fractional time, sample accurate).
    const at = 0.123456;
    let x = await render(1, sr, (e) => e.play([{ t: 0, dur: 0.4, midi: 69, vel: 1 }], { at }));
    out.onsetErrorMs = (firstAbove(x, 0.0005) / sr - at) * 1000;

    // 2. Pitch: A4 is 440 Hz.
    x = await render(1.5, sr, (e) => e.play([{ t: 0, dur: 1, midi: 69, vel: 1 }], { at: 0.1 }));
    out.a4PeakHz = peakFreq(x, sr, 0.3, 0.9, 420, 460, 0.25);

    // 3. Harmonic perfect fifth contains C4 and G4 and not the notes between.
    x = await render(1.5, sr, (e) =>
      e.play([{ t: 0, dur: 1, midi: 60, vel: 1 }, { t: 0, dur: 1, midi: 67, vel: 1 }], { at: 0.1 }));
    const mag = (f) => goertzel(x, Math.floor(0.3 * sr), Math.floor(0.9 * sr), f, sr);
    out.fifth = { c4: mag(261.626), g4: mag(391.995), eFlat4: mag(311.127), ratioToOffNote: Math.min(mag(261.626), mag(391.995)) / mag(311.127) };

    // 4. Loud chord and a pile-up of notes stay below full scale.
    x = await render(2, sr, (e) =>
      e.play([48, 60, 64, 67].map((m) => ({ t: 0, dur: 1, midi: m, vel: 1 })), { at: 0.1 }));
    out.chordPeak = peak(x);
    x = await render(2, sr, (e) =>
      e.play(Array.from({ length: 16 }, (_, i) => ({ t: 0, dur: 1, midi: 40 + i * 3, vel: 1 })), { at: 0.1 }));
    out.pileupPeak = peak(x);

    // 5. Replacing playback is click-free. The cut is placed where a 440 Hz
    // sine is near its peak, so an abrupt stop would show as a large step.
    const cutAt = 1.0 + 0.25 / 440;
    const replaceJump = async (fadeMs) => {
      const y = await render(2, sr, (e) => {
        const a = e.play([{ t: 0, dur: 3, midi: 69, vel: 1 }], { at: 0 });
        e.stop(a, { at: cutAt, fadeMs });
      });
      return maxJump(y, Math.floor(0.95 * sr), Math.floor(1.1 * sr));
    };
    out.replaceFade15msMaxJump = await replaceJump(15);
    out.replaceHardCutMaxJump = await replaceJump(0);
    out.steadyMaxJump = maxJump(
      await render(1, sr, (e) => e.play([{ t: 0, dur: 1, midi: 69, vel: 1 }], { at: 0 })),
      Math.floor(0.5 * sr),
      Math.floor(0.6 * sr));

    // 6. Nothing is left running after a stop.
    const octx = new OfflineAudioContext(1, sr, sr);
    const eng = create(octx);
    const id = eng.play([{ t: 0, dur: 5, midi: 60 }], { at: 0 });
    eng.stop(id, { at: 0.1, fadeMs: 10 });
    await octx.startRendering();
    out.groupsAfterStop = eng.activeGroups();

    return out;
  }

  window.OvertoneAudio = { create, selfTest, midiToFreq };
  window.overtoneAudio = create(null);
})();
