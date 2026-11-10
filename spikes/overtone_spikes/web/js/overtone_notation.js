// Spike S3: thin wrapper around OpenSheetMusicDisplay. The Flutter side only
// uses this API (load, highlight, clear, onNoteClick, notes, dispose).
(function () {
  'use strict';

  const STEP_BY_FUNDAMENTAL = { 0: 'C', 2: 'D', 4: 'E', 5: 'F', 7: 'G', 9: 'A', 11: 'B' };

  function attach(container) {
    const OSMD = window.opensheetmusicdisplay.OpenSheetMusicDisplay;
    const osmd = new OSMD(container, {
      autoResize: false,
      backend: 'svg',
      drawTitle: false,
      drawPartNames: false,
    });

    let index = [];
    let clickCb = null;
    let highlighted = [];
    let highlightColor = '#d81b60';
    let resizeTimer = null;
    let loaded = false;

    function describe(src) {
      const p = src.Pitch;
      const step = STEP_BY_FUNDAMENTAL[p.FundamentalNote] || '?';
      const acc = p.Accidental; // OSMD AccidentalEnum: 0 sharp, 1 flat, 2 none, 3 natural, 4 double sharp, 5 double flat
      const alter = { 0: '#', 1: 'b', 2: '', 3: '', 4: '##', 5: 'bb' }[acc] || '';
      const octave = p.Octave + 3;
      return { name: step + alter + octave, midi: src.halfTone + 12 };
    }

    function rebuildIndex() {
      index = [];
      const sheet = osmd.GraphicSheet;
      sheet.MeasureList.forEach((staves, m) => {
        staves.forEach((gm, s) => {
          if (!gm) return;
          gm.staffEntries.forEach((se, e) => {
            se.graphicalVoiceEntries.forEach((gve, v) => {
              const entries = [];
              gve.notes.forEach((gn, n) => {
                const src = gn.sourceNote;
                if (!src || src.isRest()) return;
                const g = gn.getSVGGElement ? gn.getSVGGElement() : null;
                const d = describe(src);
                entries.push({
                  g, graphicalNote: gn, head: null,
                  ref: { measure: m + 1, staff: s + 1, entry: e, voice: v, note: n },
                  name: d.name, midi: d.midi,
                });
              });
              // VexFlow draws a chord's noteheads from the lowest pitch up.
              const heads = entries.length && entries[0].g
                ? entries[0].g.querySelectorAll('.vf-notehead') : [];
              [...entries].sort((a, b) => a.midi - b.midi).forEach((it, k) => {
                it.head = heads.length === entries.length ? heads[k] : null;
              });
              index.push(...entries);
            });
          });
        });
      });
    }

    function paint(items, color) {
      for (const it of items) {
        // Chords: colour only this note's head. Single notes: the whole glyph.
        const targets = it.head && it.g.querySelectorAll('.vf-notehead').length > 1
          ? [it.head] : (it.g ? it.g.querySelectorAll('path, text') : []);
        targets.forEach((el) => {
          el.style.fill = color === null ? '' : color;
          el.style.stroke = color === null ? '' : color;
          el.querySelectorAll('path, text').forEach((c) => {
            c.style.fill = color === null ? '' : color;
            c.style.stroke = color === null ? '' : color;
          });
        });
      }
    }

    function sameRef(a, b) {
      return a.measure === b.measure && a.staff === b.staff && a.entry === b.entry &&
        a.voice === b.voice && a.note === b.note;
    }

    function applyHighlight() {
      paint(index, null);
      paint(index.filter((it) => highlighted.some((h) => sameRef(h, it.ref))), highlightColor);
    }

    function rerender() {
      if (!loaded || container.clientWidth === 0) return;
      osmd.render();
      rebuildIndex();
      applyHighlight();
    }

    container.addEventListener('click', (ev) => {
      if (!clickCb) return;
      const hit = index.find((it) => it.head && it.head.contains(ev.target)) ||
        index.find((it) => it.g && it.g.contains(ev.target) && !it.head) ||
        index.find((it) => it.g && it.g.contains(ev.target));
      if (hit) clickCb({ ...hit.ref, name: hit.name, midi: hit.midi });
    });

    const ro = new ResizeObserver(() => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(rerender, 150);
    });
    ro.observe(container);

    return {
      async load(xml) {
        await osmd.load(xml);
        // The platform view can exist before layout gives it a width.
        for (let i = 0; i < 120 && container.clientWidth === 0; i++) {
          await new Promise((r) => requestAnimationFrame(r));
        }
        loaded = true;
        osmd.render();
        rebuildIndex();
        highlighted = [];
        return { measures: osmd.GraphicSheet.MeasureList.length, notes: index.length };
      },
      async loadUrl(url) {
        const res = await fetch(url);
        if (!res.ok) throw new Error('HTTP ' + res.status + ' for ' + url);
        return this.load(await res.text());
      },
      notes() {
        return index.map((it) => ({ ...it.ref, name: it.name, midi: it.midi }));
      },
      highlight(refs, color) {
        highlighted = refs;
        if (color) highlightColor = color;
        applyHighlight();
      },
      clear() {
        highlighted = [];
        applyHighlight();
      },
      onNoteClick(cb) {
        clickCb = cb;
      },
      rerender,
      dispose() {
        ro.disconnect();
        clickCb = null;
        osmd.clear();
      },
    };
  }

  window.OvertoneNotation = { attach };
})();
