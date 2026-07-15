// Design-direction preview: three complete visual languages rendered with the
// app's real content shapes (header, status rail, messages, tool rows, lane
// card, composer, session card) and mock data — swipeable side by side on a
// real phone. Pick one; it then becomes the app-wide theme. Self-contained on
// purpose: local palettes, no AppColors, so directions can differ freely.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One visual direction.
class _Dir {
  final String name;
  final String blurb;
  // Surfaces
  final Color bg, surface, raised, border;
  // Text
  final Color fg1, fg2, fg3;
  // Accent + status
  final Color accent, accentFg, ok, danger;
  // Shape + type
  final double rCard, rRow;
  final TextStyle Function(double, FontWeight, Color) sans;
  final TextStyle Function(double, Color) mono;

  const _Dir({
    required this.name,
    required this.blurb,
    required this.bg,
    required this.surface,
    required this.raised,
    required this.border,
    required this.fg1,
    required this.fg2,
    required this.fg3,
    required this.accent,
    required this.accentFg,
    required this.ok,
    required this.danger,
    required this.rCard,
    required this.rRow,
    required this.sans,
    required this.mono,
  });
}

TextStyle _geist(double s, FontWeight w, Color c) =>
    GoogleFonts.geist(fontSize: s, fontWeight: w, color: c, height: 1.4);
TextStyle _inter(double s, FontWeight w, Color c) =>
    GoogleFonts.inter(fontSize: s, fontWeight: w, color: c, height: 1.45);
TextStyle _ibmSans(double s, FontWeight w, Color c) =>
    GoogleFonts.ibmPlexSans(fontSize: s, fontWeight: w, color: c, height: 1.45);
TextStyle _jet(double s, Color c) =>
    GoogleFonts.jetBrainsMono(fontSize: s, color: c, height: 1.5);
TextStyle _ibmMono(double s, Color c) =>
    GoogleFonts.ibmPlexMono(fontSize: s, color: c, height: 1.5);
TextStyle _commit(double s, Color c) =>
    GoogleFonts.sourceCodePro(fontSize: s, color: c, height: 1.5);

final _directions = <_Dir>[
  // A — refinement of today's warm coral, with real hierarchy discipline.
  _Dir(
    name: 'Warm Studio',
    blurb: 'Today\'s warm charcoal + coral, disciplined: quieter borders, tighter type, clearer elevation.',
    bg: const Color(0xFF12110F),
    surface: const Color(0xFF1B1A17),
    raised: const Color(0xFF262421),
    border: const Color(0x14FFFFFF),
    fg1: const Color(0xFFF3F1EC),
    fg2: const Color(0xFFBEBAB0),
    fg3: const Color(0xFF868278),
    accent: const Color(0xFFE07B57),
    accentFg: const Color(0xFF2B1006),
    ok: const Color(0xFFE07B57),
    danger: const Color(0xFFFF6467),
    rCard: 14,
    rRow: 9,
    sans: _geist,
    mono: _jet,
  ),
  // B — cool graphite, Linear/Vercel-like crispness, electric accent.
  _Dir(
    name: 'Graphite',
    blurb: 'Neutral true-dark, hairline borders, sharp 8px corners, one electric accent. Linear-ish.',
    bg: const Color(0xFF0A0A0B),
    surface: const Color(0xFF131316),
    raised: const Color(0xFF1C1C21),
    border: const Color(0x1FFFFFFF),
    fg1: const Color(0xFFEDEDEF),
    fg2: const Color(0xFFB4B4BE),
    fg3: const Color(0xFF75757F),
    accent: const Color(0xFF5E8BFF),
    accentFg: const Color(0xFF0A0A0B),
    ok: const Color(0xFF62C99A),
    danger: const Color(0xFFF5606B),
    rCard: 8,
    rRow: 6,
    sans: _inter,
    mono: _ibmMono,
  ),
  // C — terminal ink: near-black, mono-forward, chrome almost invisible.
  _Dir(
    name: 'Terminal Ink',
    blurb: 'Near-black, mono-forward, barely-there chrome; color used ONLY for state. Warp-ish.',
    bg: const Color(0xFF060707),
    surface: const Color(0xFF0D0F0F),
    raised: const Color(0xFF151818),
    border: const Color(0x17FFFFFF),
    fg1: const Color(0xFFE8ECEA),
    fg2: const Color(0xFFAAB2AE),
    fg3: const Color(0xFF6C7370),
    accent: const Color(0xFFE0A458),
    accentFg: const Color(0xFF160E02),
    ok: const Color(0xFF7BC49A),
    danger: const Color(0xFFE86A6A),
    rCard: 10,
    rRow: 6,
    sans: _ibmSans,
    mono: _commit,
  ),
];

class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});
  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  final _page = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final d = _directions[_index];
    return Scaffold(
      backgroundColor: d.bg,
      body: SafeArea(
        child: Column(children: [
          // Direction switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(Icons.chevron_left, color: d.fg2, size: 26),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${_index + 1}/3 · ${d.name}', style: d.sans(16, FontWeight.w700, d.fg1)),
                  Text(d.blurb, maxLines: 2, style: d.sans(11, FontWeight.w400, d.fg3)),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              onPageChanged: (i) => setState(() => _index = i),
              children: [for (final dir in _directions) _mock(dir)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('swipe ⟷ to compare directions', style: d.sans(11, FontWeight.w400, d.fg3)),
          ),
        ]),
      ),
    );
  }

  // One full mock: session list card, then the session screen chrome.
  Widget _mock(_Dir d) {
    Widget divider() => Container(height: 1, color: d.border, margin: const EdgeInsets.symmetric(vertical: 10));

    return Container(
      color: d.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
        children: [
          // --- session list card ---
          Text('SESSION LIST', style: d.mono(9.5, d.fg3)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: d.surface,
              borderRadius: BorderRadius.circular(d.rCard),
              border: Border.all(color: d.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('fix the auth refresh bug', style: d.sans(14, FontWeight.w600, d.fg1))),
                Text('2m', style: d.mono(10.5, d.fg3)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(color: d.accent, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Text('Running', style: d.sans(11.5, FontWeight.w500, d.accent)),
                Text('  ·  wacht  ·  qwen-ocgo', style: d.mono(10.5, d.fg3)),
              ]),
            ]),
          ),
          divider(),

          // --- session header + rail ---
          Text('SESSION', style: d.mono(9.5, d.fg3)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: d.surface,
              borderRadius: BorderRadius.circular(d.rCard),
              border: Border.all(color: d.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(children: [
                  Icon(Icons.chevron_left, size: 20, color: d.fg2),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('fix the auth refresh bug', style: d.sans(14.5, FontWeight.w600, d.fg1)),
                      Text('Running · qwen-ocgo', style: d.sans(10.5, FontWeight.w400, d.fg3)),
                    ]),
                  ),
                ]),
              ),
              // status rail
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: d.border), bottom: BorderSide(color: d.border))),
                child: Row(children: [
                  SizedBox(
                    width: 30, height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(value: .41, backgroundColor: d.raised, color: d.accent),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('41%', style: d.mono(10.5, d.fg2)),
                  _railDot(d), Text('↑1.2M ↓84k', style: d.mono(10.5, d.fg3)),
                  _railDot(d), Text('◆ 2', style: d.mono(10.5, d.accent)),
                  _railDot(d), Text('◉ 1', style: d.mono(10.5, d.fg3)),
                  _railDot(d), Text('auto', style: d.mono(10.5, d.fg3)),
                ]),
              ),
              // transcript
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('You', style: d.sans(12, FontWeight.w600, d.fg2)),
                  const SizedBox(height: 3),
                  Text('also check the refresh path and add a test',
                      style: d.sans(14, FontWeight.w400, d.fg1)),
                  const SizedBox(height: 12),

                  // tool run
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(border: Border(left: BorderSide(color: d.border, width: 2))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _tool(d, '✓', 'bash', 'cargo test -p auth', 'exit 0'),
                      _tool(d, '✓', 'edit_file', 'src/auth/refresh.rs', '+12 −3'),
                      _tool(d, '⠿', 'bash', 'cargo clippy --all-targets', ''),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // lane card
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: d.raised,
                      borderRadius: BorderRadius.circular(d.rRow + 2),
                      border: Border.all(color: d.accent.withValues(alpha: .35)),
                    ),
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: d.accent, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('audit the session-token flow', style: d.sans(12.5, FontWeight.w600, d.fg1))),
                      Text('running · 2m 14s', style: d.mono(10.5, d.accent)),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  Text('Snippet', style: d.sans(12, FontWeight.w600, d.accent)),
                  const SizedBox(height: 3),
                  Text('Found it — the refresh path drops the rotation window when the clock skews. Fixing and re-running the suite.',
                      style: d.sans(14, FontWeight.w400, d.fg1)),
                ]),
              ),
              // composer
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
                decoration: BoxDecoration(
                  color: d.raised,
                  borderRadius: BorderRadius.circular(d.rCard),
                  border: Border.all(color: d.border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('Message snippet…', style: d.sans(13.5, FontWeight.w400, d.fg3)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Spacer(),
                    Icon(Icons.add, size: 19, color: d.fg2),
                    const SizedBox(width: 10),
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: d.accent, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_upward, size: 17, color: d.accentFg),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
          divider(),

          // --- palette strip ---
          Text('PALETTE', style: d.mono(9.5, d.fg3)),
          const SizedBox(height: 6),
          Row(children: [
            for (final c in [d.bg, d.surface, d.raised, d.accent, d.ok, d.danger])
              Expanded(
                child: Container(
                  height: 26,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5), border: Border.all(color: d.border)),
                ),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _railDot(_Dir d) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Container(width: 1, height: 10, color: d.border),
      );

  Widget _tool(_Dir d, String glyph, String name, String arg, String meta) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(width: 14, child: Text(glyph, style: d.mono(11, glyph == '✗' ? d.danger : d.fg3))),
          const SizedBox(width: 5),
          Text(name, style: d.mono(11.5, d.fg2)),
          const SizedBox(width: 7),
          Expanded(child: Text(arg, maxLines: 1, overflow: TextOverflow.ellipsis, style: d.mono(11.5, d.fg3))),
          if (meta.isNotEmpty) Text(meta, style: d.mono(10.5, d.fg3)),
        ]),
      );
}
