import 'package:flutter/material.dart';
import 'package:synonyms/managers/synonym_manager.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Synonym Finder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(15, 113, 184, 1),
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: AnimatedSplashScreen(
        splash: _buildSplashContent(context),
        nextScreen: const SynonymPage(),
        splashIconSize: MediaQuery.of(context).size.height,
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        backgroundColor: const Color.fromRGBO(15, 113, 184, 1),
        duration: 3000,
      ),
    );
  }

  Widget _buildSplashContent(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.language,
          color: Colors.white,
          size: 100,
        ),
        SizedBox(height: 20),
        Text(
          "Synonym Finder",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Discover Words. Simplified.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class SynonymPage extends StatefulWidget {
  const SynonymPage({super.key});

  @override
  State<SynonymPage> createState() => _SynonymPageState();
}

class _SynonymPageState extends State<SynonymPage> {
  final SynonymManager _synonymManager = SynonymManager();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _synonymController = TextEditingController();
  String _result = "";

  Map<String, String> textFieldsErrors = {};

  bool addSynonymSubmitted = false;
  bool findSynonymSubmitted = false;

  void _addSynonym() {
    if (mounted && !addSynonymSubmitted) {
      setState(() {
        addSynonymSubmitted = true;
        findSynonymSubmitted = false;
      });
    }
    textFieldsErrors.clear();
    bool isValid = true;
    final word = _wordController.text.trim();
    final synonym = _synonymController.text.trim();

    if (word.isEmpty && mounted) {
      setState(() {
        textFieldsErrors['word'] = "Field is required";
      });
      isValid = false;
    }
    if (synonym.isEmpty && mounted) {
      setState(() {
        textFieldsErrors['synonym'] = "Field is required";
      });
      isValid = false;
    }

    if (!isValid) return;

    if (word.isNotEmpty && synonym.isNotEmpty) {
      setState(() {
        _synonymManager.addSynonym(word, synonym);
        _result = "Synonym added: $word <-> $synonym";
        addSynonymSubmitted = false;
      });
    }
  }

  void _lookupSynonyms() {
    if (mounted && !findSynonymSubmitted) {
      setState(() {
        addSynonymSubmitted = false;
        findSynonymSubmitted = true;
      });
    }

    textFieldsErrors.clear();
    final word = _wordController.text.trim();

    if (word.isEmpty && mounted) {
      setState(() {
        textFieldsErrors['word'] = "Field is required";
      });
      return;
    }

    if (word.isNotEmpty) {
      setState(() {
        final synonyms = _synonymManager.getSynonyms(word);
        _result = synonyms.isEmpty ? "No synonyms found." : "Synonyms for $word: ${synonyms.join(", ")}";
        findSynonymSubmitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Synonym Finder",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(15, 113, 184, 1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Discover Synonyms Instantly",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(15, 113, 184, 1),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputCard(),
              const SizedBox(height: 24),
              if (_result.isNotEmpty) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ..._buildTextField(
              _wordController,
              "Enter a word",
              Icons.text_fields,
              (value) => {
                    if ((addSynonymSubmitted || findSynonymSubmitted) && value.trim().isEmpty && mounted)
                      {
                        setState(() {
                          textFieldsErrors['word'] = "Field is required";
                        })
                      }
                    else if (mounted)
                      {
                        setState(() {
                          textFieldsErrors.remove('word');
                        })
                      }
                  },
              errorText: textFieldsErrors['word']),
          const SizedBox(height: 16),
          ..._buildTextField(
              _synonymController,
              "Enter a synonym",
              Icons.sync_alt,
              (value) => {
                    if (addSynonymSubmitted && value.trim().isEmpty && mounted)
                      {
                        setState(() {
                          textFieldsErrors['synonym'] = "Field is required";
                        })
                      }
                    else if (mounted)
                      {
                        setState(() {
                          textFieldsErrors.remove('synonym');
                        })
                      }
                  },
              errorText: textFieldsErrors['synonym']),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addSynonym,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color.fromRGBO(15, 113, 184, 1),
                  ),
                  child: const Text(
                    "Add Synonym",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _lookupSynonyms,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color.fromRGBO(15, 113, 184, 1),
                  ),
                  child: const Text(
                    "Find Synonyms",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _result,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  List<Widget> _buildTextField(TextEditingController controller, String hintText, IconData icon, Function(String value) onChanged,
      {String? errorText}) {
    return [
      TextField(
        controller: controller,
        onTap: () {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color.fromRGBO(15, 113, 184, 1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.transparent,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.transparent,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.transparent,
              width: 1,
            ),
          ),
          errorStyle: const TextStyle(height: 0),
        ),
      ),
      if (errorText != null)
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                errorText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
    ];
  }
}
