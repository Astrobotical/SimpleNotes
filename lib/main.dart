import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mynotes/Models/NoteModel.dart';
import 'package:mynotes/dbHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: const MyHomePage(title: 'My Notes App'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseConnectionHandler connectionString = DatabaseConnectionHandler();
  int _counter = 0;
  late BuildContext scaffoldContext;
  TextEditingController noteName = TextEditingController();
  TextEditingController noteDescription = TextEditingController();
  bool hasUpdated = false;
  List<NoteModel> notes = [];
  @override
  void initState() {
    super.initState();
    connectionString.DB;
  }

  Future<List<NoteModel>> getNotes() async {
    notes = await connectionString.getData();
    return notes;
  }

  void addNote() async {
    hasUpdated = false;
    NoteModel note = NoteModel(
        id: 0, noteName: noteName.text, noteDescription: noteDescription.text);
    int results = await connectionString.insertData(note);
    if (results == 1) {
      noteName.clear();
      noteDescription.clear();
    }
    setState(() {
      {
        hasUpdated = true;
      }
    });
    await getNotes();
  }

  void editNote(NoteModel note) async {
    setState(() {
      hasUpdated = false;
    });
    showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Edit Note',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: noteName..text = note.noteName,
                      decoration: const InputDecoration(
                        hintText: 'Enter Note Name',
                      ),
                    ),
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: noteDescription..text = note.noteDescription,
                      decoration: const InputDecoration(
                        hintText: 'Note Description',
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(scaffoldContext);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () async {
                          await connectionString.updateData(note);
                          setState(() {
                            {
                              hasUpdated = true;
                            }
                          });
                          await getNotes();
                          Navigator.pop(scaffoldContext);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void deleteNote(int id) async {
    setState(() {
      hasUpdated = false;
    });
    await connectionString.deleteData(id);
    setState(() {
      {
        hasUpdated = true;
      }
    });
    await getNotes();
  }

  void showModal() {
    showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Add Note',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: noteName,
                      decoration: const InputDecoration(
                        hintText: 'Enter Note Name',
                      ),
                    ),
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: noteDescription,
                      decoration: const InputDecoration(
                        hintText: 'Note Description',
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(scaffoldContext);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          addNote();
                          Navigator.pop(scaffoldContext);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: hasUpdated
          ? ListView.builder(
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(notes[index].noteName),
                  subtitle: Text(notes[index].noteDescription),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          editNote(notes[index]);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteNote(notes[index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          : FutureBuilder(
              future: getNotes(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<NoteModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Notes Found'),
                  );
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(snapshot.data![index].noteName),
                      subtitle: Text(snapshot.data![index].noteDescription),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editNote(snapshot.data![index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteNote(snapshot.data![index].id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: showModal,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
