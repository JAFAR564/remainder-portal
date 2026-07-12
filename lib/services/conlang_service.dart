import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single vocabulary entry in the Ethereal Scribe conlang.
class ConlangTerm {
  final String word;
  final String pronunciation;
  final String etymology;
  final String meaning;
  final String systemFunction;

  const ConlangTerm({
    required this.word,
    required this.pronunciation,
    required this.etymology,
    required this.meaning,
    required this.systemFunction,
  });
}

/// Service governing conlang dictionary lookup and validation.
class ConlangService {
  final List<ConlangTerm> terms = const [
    ConlangTerm(
      word: 'Amatsukrion',
      pronunciation: 'Ah-mah-tsoo-kree-on',
      etymology: 'Jap. Amatsu (Heavenly) + Grk. Kritos (Chosen/Judge)',
      meaning: 'Divine celestial arbiter.',
      systemFunction: 'System-level audit tool used to resolve localized physics conflicts.',
    ),
    ConlangTerm(
      word: 'Wyrd-Kaze',
      pronunciation: 'Weird-Kah-zeh',
      etymology: 'O.E. Wyrd (Fate) + Jap. Kaze (Wind)',
      meaning: 'Destructive reality storm.',
      systemFunction: 'Server-wide event that randomizes active sector parameters.',
    ),
    ConlangTerm(
      word: 'Aetheromaru',
      pronunciation: 'Eye-theh-roh-mah-roo',
      etymology: 'Grk. Aether (Void) + Jap. Maru (Sacred Circle)',
      meaning: 'Local reality-stabilizing anchor.',
      systemFunction: 'Portable inventory item that establishes a localized safe zone.',
    ),
    ConlangTerm(
      word: 'Eld-Sombra',
      pronunciation: 'Eld-Som-brah',
      etymology: 'O.E. Eld (Ancient) + Span. Sombra (Shadow)',
      meaning: 'Residual kinetic imprint.',
      systemFunction: 'Unlocks stealth modifiers and shadows active coordinate tracking.',
    ),
    ConlangTerm(
      word: 'Cyning-Bushi',
      pronunciation: 'Koo-ning-Boo-shee',
      etymology: 'O.E. Cyning (King) + Jap. Bushi (Warrior)',
      meaning: 'Cybernetic sentinel.',
      systemFunction: 'Sentinel class archetype that provides defensive bonuses.',
    ),
    ConlangTerm(
      word: 'Thalassovael',
      pronunciation: 'Tha-las-so-vale',
      etymology: 'Grk. Thalassa (Sea) + Fr. -vael (Fantasy Suffix)',
      meaning: 'Shimmering liquid neon ocean.',
      systemFunction: 'Imposes fluid drift physics and reduces movement speed.',
    ),
    ConlangTerm(
      word: 'Tsukuyomnos',
      pronunciation: 'Tsoo-koo-yom-nohs',
      etymology: 'Jap. Tsukuyomi (Moon God) + Grk. Chronos (Time)',
      meaning: 'Relic temporal pocketwatch.',
      systemFunction: 'Decelerates localized action timers and cooldown loops.',
    ),
    ConlangTerm(
      word: 'L’Étoile Kami',
      pronunciation: 'Leh-twahl Kah-mee',
      etymology: 'Fr. L\'Étoile (The Star) + Jap. Kami (Divine Spirit)',
      meaning: 'Sacred celestial entity.',
      systemFunction: 'Multiplies narrative favor when communicating with AI factions.',
    ),
    ConlangTerm(
      word: 'Bann-Fuego',
      pronunciation: 'Bahn-Fweh-goh',
      etymology: 'O.E. Bann (Proclamation) + Span. Fuego (Fire)',
      meaning: 'Defensive programmatic firewall.',
      systemFunction: 'Tactical shield block that mitigates corruption attacks.',
    ),
    ConlangTerm(
      word: 'Ginn-Ouro',
      pronunciation: 'Gihn-Ow-roh',
      etymology: 'O.E. Ginn (Infinite) + Grk. Ouroboros (Tail-Eater)',
      meaning: 'Core algorithmic paradox loop.',
      systemFunction: 'Causes localized resource deposits to multiply rapidly.',
    ),
    ConlangTerm(
      word: 'Cheval-Astros',
      pronunciation: 'Sheh-val-As-trohs',
      etymology: 'Fr. Cheval (Horse) + Grk. Astron (Star)',
      meaning: 'High-speed celestial mount.',
      systemFunction: 'Modifies and speeds up transitions between sector boundaries.',
    ),
    ConlangTerm(
      word: 'Cuerpo-Kernel',
      pronunciation: 'Kwer-poh-Ker-nel',
      etymology: 'Span. Cuerpo (Body) + O.E. Kernel (Core)',
      meaning: 'Physical hardware chassis.',
      systemFunction: 'Governs the maximum inventory slots a character can hold.',
    ),
    ConlangTerm(
      word: 'Esprit-Shin',
      pronunciation: 'Es-pree-Sheen',
      etymology: 'Fr. Esprit (Spirit) + Jap. Shin (Heart)',
      meaning: 'Code logic of an individual soul.',
      systemFunction: 'Modulates conversational AI empathy and affinity.',
    ),
    ConlangTerm(
      word: 'Saber-Nomos',
      pronunciation: 'Sah-behr-Noh-mohs',
      etymology: 'Span. Saber (Knowledge) + Grk. Nomos (Law)',
      meaning: 'Structured codex of world laws.',
      systemFunction: 'Item used to unlock high-level sector building commands.',
    ),
    ConlangTerm(
      word: 'Foret-Bruma',
      pronunciation: 'For-ay-Broo-mah',
      etymology: 'Fr. Forêt (Forest) + Span. Bruma (Mist)',
      meaning: 'Obfuscated hidden node directory.',
      systemFunction: 'Hides coordinates from maps, completely preventing scans.',
    ),
    ConlangTerm(
      word: 'Mano-Graphein',
      pronunciation: 'Mah-noh-Grah-fayn',
      etymology: 'Span. Mano (Hand) + Grk. Graphein (To Write)',
      meaning: 'Direct write operation.',
      systemFunction: 'Overwrites structural YAML parameters of a targeted item.',
    ),
    ConlangTerm(
      word: 'Heorot-Maison',
      pronunciation: 'Hey-oh-roht-May-zohn',
      etymology: 'O.E. Heorot (Hall) + Fr. Maison (House)',
      meaning: 'Safe stronghold sanctuary.',
      systemFunction: 'Regenerates resource and structural charges when inside.',
    ),
    ConlangTerm(
      word: 'Ananke-Kaze',
      pronunciation: 'Ah-nahn-keh-Kah-zeh',
      etymology: 'Grk. Ananke (Necessity) + Jap. Kaze (Wind)',
      meaning: 'Fatalistic weather event.',
      systemFunction: 'Triggers natural environmental reset cycles.',
    ),
    ConlangTerm(
      word: 'Reina-Koku',
      pronunciation: 'Ray-nah-Koh-koo',
      etymology: 'Span. Reina (Queen) + Jap. Koku (Domain)',
      meaning: 'Sovereign administrative AI agent.',
      systemFunction: 'Directs and coordinates high-tier faction missions.',
    ),
    ConlangTerm(
      word: 'Hreow-Larme',
      pronunciation: 'Hree-ow-Lahrm',
      etymology: 'O.E. Hreow (Regret) + Fr. Larme (Tear)',
      meaning: 'Condensed timeline remnant.',
      systemFunction: 'High-tier crafting ingredient used to upgrade ancient items.',
    ),
    ConlangTerm(
      word: 'Soma-Techos',
      pronunciation: 'Soh-mah-Teh-chos',
      etymology: 'Grk. Soma (Body) + Span. Techo (Roof/Wall)',
      meaning: 'Defensive fortification shield.',
      systemFunction: 'Negates physical and kinetic impact damage in combat.',
    ),
    ConlangTerm(
      word: 'Nihon-Mecanique',
      pronunciation: 'Nee-hohn-Meh-cah-neek',
      etymology: 'Jap. Nihon (Sun) + Fr. Mécanique (Mechanism)',
      meaning: 'Solar automation engine.',
      systemFunction: 'Passively generates resources when anchored in high-light sectors.',
    ),
    ConlangTerm(
      word: 'Guerra-Bushi',
      pronunciation: 'Gher-rah-Boo-shee',
      etymology: 'Span. Guerra (War) + Jap. Bushi (Warrior)',
      meaning: 'Elite combat specialist.',
      systemFunction: 'Multiplies the accuracy and success of offensive maneuvers.',
    ),
    ConlangTerm(
      word: 'Scribe-Logos',
      pronunciation: 'Scribe-Log-ohs',
      etymology: 'Fr. Scribe (Writer) + Grk. Logos (Reason)',
      meaning: 'Local execution compiler agent.',
      systemFunction: 'Evaluates spelling and formatting rules in user actions.',
    ),
    ConlangTerm(
      word: 'Ald-Logos',
      pronunciation: 'AHld-Log-ohs',
      etymology: 'O.E. Ald (Old) + Grk. Logos (Word)',
      meaning: 'Archaic dialect database.',
      systemFunction: 'Activates historical syntax constraints in specific areas.',
    ),
    ConlangTerm(
      word: 'Chronos-Vida',
      pronunciation: 'Kroh-nohs-Vee-dah',
      etymology: 'Grk. Chronos (Time) + Span. Vida (Life)',
      meaning: 'Biological lifetime duration tracker.',
      systemFunction: 'Tracks mutation stages and unlocks genetic branches.',
    ),
    ConlangTerm(
      word: 'Komorebi-Ciel',
      pronunciation: 'Koh-moh-reh-bee-See-el',
      etymology: 'Jap. Komorebi (Dappled light) + Fr. Ciel (Sky)',
      meaning: 'Translucent lighting filter.',
      systemFunction: 'Adjusts local UI theme colors and transparency.',
    ),
    ConlangTerm(
      word: 'Sangre-Wyrd',
      pronunciation: 'San-greh-Weird',
      etymology: 'Span. Sangre (Blood) + O.E. Wyrd (Fate)',
      meaning: 'Shared genetic lineage indicator.',
      systemFunction: 'Restricts access to ancient ancestral weapon vaults.',
    ),
    ConlangTerm(
      word: 'Necro-Mano',
      pronunciation: 'Neh-croh-Mah-noh',
      etymology: 'Grk. Nekros (Dead) + Span. Mano (Hand)',
      meaning: 'System-level moderation override.',
      systemFunction: 'Clears non-compliant files from regional database tables.',
    ),
    ConlangTerm(
      word: 'Yugen-Maison',
      pronunciation: 'Yoo-ghen-May-zohn',
      etymology: 'Jap. Yūgen (Grace/Mystery) + Fr. Maison (House)',
      meaning: 'Central portal hub.',
      systemFunction: 'Serves as the primary coordinate node for inter-sector travel.',
    ),
  ];

  const ConlangService();

  /// Resolves a term by word (case-insensitive)
  ConlangTerm? lookup(String word) {
    final searchWord = word.trim().toLowerCase();
    for (final term in terms) {
      if (term.word.toLowerCase() == searchWord) {
        return term;
      }
    }
    return null;
  }
}

/// Provider exposing the ConlangService
final conlangServiceProvider = Provider<ConlangService>((ref) {
  return const ConlangService();
});
