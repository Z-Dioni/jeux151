import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu de cartes 151',
      // Utilisation d'un thème Indigo plus moderne
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Card Theme global pour la cohérence
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        // Input Decoration global
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const SetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- MODÈLES ---

class Player {
  String name;
  int score;
  bool active;
  int consecutiveWins;

  Player({
    required this.name,
    this.score = 0,
    this.active = true,
    this.consecutiveWins = 0,
  });
}

class RoundResult {
  int roundNumber;
  int? winnerIndex;
  Map<int, dynamic> playerResults;

  RoundResult({
    required this.roundNumber,
    this.winnerIndex,
    required this.playerResults,
  });
}

// --- ÉCRAN DE CONFIGURATION ---

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Player> _players = [];

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && _players.length < 6) {
      setState(() {
        _players.add(Player(name: name));
        _nameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _startGame() {
    if (_players.length >= 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GameScreen(players: _players)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text(
          'Configuration 151',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // // Bouton Reset existant
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: _resetGame,
          //   tooltip: 'Nouvelle partie',
          // ),
          // // --- NOUVEAU BOUTON INFO ---
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'À propos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          // ---------------------------
          const SizedBox(width: 8), // Petite marge à droite
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ), // Pour éviter que ce soit trop large sur PC
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carte d'ajout
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nouveau joueur',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Ex: Thomas',
                                  labelText: 'Nom',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                onSubmitted: (_) => _addPlayer(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FloatingActionButton.small(
                              onPressed: _players.length < 6
                                  ? _addPlayer
                                  : null,
                              child: const Icon(Icons.add),
                              elevation: 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_players.length}/6 joueurs',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Liste des joueurs
                Expanded(
                  child: _players.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.groups_outlined,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ajoutez au moins 2 joueurs',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _players.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer.withOpacity(0.4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    _players[index].name[0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  _players[index].name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removePlayer(index),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _players.length >= 2 ? _startGame : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'DÉMARRER LA PARTIE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- ÉCRAN DE JEU ---

class GameScreen extends StatefulWidget {
  final List<Player> players;

  const GameScreen({super.key, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Player> _players;
  final List<RoundResult> _roundHistory = [];
  int _currentRound = 1;
  int? _winnerIndex;
  final Map<int, TextEditingController> _scoreControllers = {};
  bool _gameEnded = false;
  String? _finalWinner;

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.players);
    for (int i = 0; i < _players.length; i++) {
      _scoreControllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _validateRound() {
    if (_winnerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Qui a gagné cette manche ?'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Map<int, dynamic> playerResults = {};
    for (int i = 0; i < _players.length; i++) {
      if (i == _winnerIndex) {
        playerResults[i] = 'V';
      } else if (!_players[i].active) {
        playerResults[i] = '☠️'; // Symbole mort
      } else {
        final points = int.tryParse(_scoreControllers[i]!.text) ?? 0;
        playerResults[i] = points;
      }
    }

    setState(() {
      _roundHistory.insert(
        0, // Ajouter au début pour avoir le plus récent en haut
        RoundResult(
          roundNumber: _currentRound,
          winnerIndex: _winnerIndex,
          playerResults: playerResults,
        ),
      );

      for (int i = 0; i < _players.length; i++) {
        if (i == _winnerIndex) {
          _players[i].consecutiveWins++;
        } else if (_players[i].active) {
          final points = int.tryParse(_scoreControllers[i]!.text) ?? 0;
          _players[i].score += points;
          _players[i].consecutiveWins = 0;
        }
      }

      _applySpecialRules();
      _checkGameEnd();

      if (!_gameEnded) {
        _currentRound++;
        _winnerIndex = null;
        for (var controller in _scoreControllers.values) {
          controller.clear();
        }
      }
    });
  }

  void _applySpecialRules() {
    for (int i = 0; i < _players.length; i++) {
      if (!_players[i].active) continue;

      if (_players[i].score == 151) {
        _players[i].score -= 10;
        _showToast("${_players[i].name} tombe sur 151 ! (-10pts)");
      } else if (_players[i].score >= 152) {
        _players[i].active = false;
        _showToast("${_players[i].name} est éliminé !");
      }

      if (_players[i].consecutiveWins >= 3) {
        _players[i].score -= 10;
        _players[i].consecutiveWins = 0;
        _showToast("${_players[i].name} : 3 victoires ! (-10pts)");
      }

      if (_players[i].score < 0) _players[i].score = 0;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _checkGameEnd() {
    int activePlayers = 0;
    int lastActivePlayerIndex = -1;

    for (int i = 0; i < _players.length; i++) {
      if (_players[i].active) {
        activePlayers++;
        lastActivePlayerIndex = i;
      }
    }

    if (activePlayers <= 1) {
      setState(() {
        _gameEnded = true;
        if (activePlayers == 1) {
          _finalWinner = _players[lastActivePlayerIndex].name;
        } else {
          _finalWinner = "Personne (Tous éliminés)";
        }
      });
    }
  }

  void _resetGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetupScreen()),
    );
  }

  // --- WIDGET BUILDERS ---

  // 1. La Carte de Score (Input)
  Widget _buildScoreCard() {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Saisie Manche $_currentRound',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Zone scrollable pour le tableau de saisie
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width > 600
                    ? 500
                    : MediaQuery.of(context).size.width - 32,
              ),
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(
                    label: Text(
                      'JOUEUR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(label: Text('SCORE'), numeric: true),
                  DataColumn(label: Text('GAGNANT')),
                  DataColumn(label: Text('POINTS MANCHE')),
                ],
                rows: List.generate(_players.length, (index) {
                  final player = _players[index];
                  final isActive = player.active;
                  final isWinner = _winnerIndex == index;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith((states) {
                      if (!isActive) return Colors.grey.withOpacity(0.1);
                      if (isWinner) return Colors.green.withOpacity(0.1);
                      return null;
                    }),
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isActive)
                              const Text("💀 ")
                            else if (player.consecutiveWins > 0)
                              Text("🔥" * player.consecutiveWins + " "),
                            Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: !isActive
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: !isActive ? Colors.grey : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          '${player.score}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: player.score > 100
                                ? Colors.orange
                                : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Radio<int>(
                            value: index,
                            groupValue: _winnerIndex,
                            activeColor: Colors.green,
                            onChanged: (_gameEnded || !isActive)
                                ? null
                                : (value) =>
                                      setState(() => _winnerIndex = value),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _scoreControllers[index],
                            enabled:
                                _winnerIndex != index &&
                                isActive &&
                                !_gameEnded,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              fillColor:
                                  (_winnerIndex != index &&
                                      isActive &&
                                      !_gameEnded)
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _gameEnded
                ? Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆 PARTIE TERMINÉE 🏆',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Vainqueur : ${_finalWinner ?? "?"}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _validateRound,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('VALIDER LA MANCHE'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 2. La Carte d'Historique
  Widget _buildHistoryCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: const Text(
              'Historique',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _roundHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const Text(
                          'En attente de la manche 1...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowMinHeight: 40,
                        columns: [
                          const DataColumn(
                            label: Text(
                              '#',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ...List.generate(
                            _players.length,
                            (index) => DataColumn(
                              label: Text(
                                _players[index].name
                                    .substring(
                                      0,
                                      _players[index].name.length > 3
                                          ? 3
                                          : null,
                                    )
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                        rows: _roundHistory.map((round) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${round.roundNumber}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              ...List.generate(_players.length, (playerIndex) {
                                final val = round.playerResults[playerIndex];
                                final isWin = round.winnerIndex == playerIndex;
                                return DataCell(
                                  Text(
                                    '$val',
                                    style: TextStyle(
                                      fontWeight: isWin
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isWin
                                          ? Colors.green
                                          : (val == '☠️' ? Colors.red : null),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu 151'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Nouvelle partie',
          ),
        ],
      ),
      // --- CŒUR DU RESPONSIVE ---
      // LayoutBuilder permet de savoir la largeur disponible
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Si l'écran est large (Tablet, Web, Desktop) > 900px
          if (constraints.maxWidth > 900) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colonne Gauche : Saisie (Fixe 500px ou flexible)
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(child: _buildScoreCard()),
                  ),
                  const SizedBox(width: 16),
                  // Colonne Droite : Historique (Prend le reste)
                  Expanded(flex: 2, child: _buildHistoryCard()),
                ],
              ),
            );
          }
          // Si l'écran est petit (Mobile)
          else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildScoreCard(),
                  const SizedBox(height: 16),
                  // Hauteur fixe pour l'historique sur mobile pour permettre le scroll interne
                  SizedBox(height: 400, child: _buildHistoryCard()),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Fonction pour ouvrir WhatsApp
  Future<void> _launchWhatsApp() async {
    // Le numéro avec l'indicatif du Mali (223)
    final Uri url = Uri.parse('https://wa.me/22390455881');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible de lancer WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.code,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Text(
                'Jeu 151',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Cette application a été réalisée avec passion par :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Zoumana Dioni\net ses ami(e)s',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Bouton WhatsApp
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _launchWhatsApp,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF25D366,
                    ), // Couleur WhatsApp
                  ),
                  icon: const Icon(
                    Icons.message,
                  ), // Ou une icône WhatsApp si vous en avez une
                  label: const Text(
                    'Nous contacter sur WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '+223 90 45 58 81',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
