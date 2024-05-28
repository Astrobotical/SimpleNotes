

class NoteModel{
  int id;
  String noteName;
  String noteDescription;
  NoteModel({required this.id,required this.noteName,required this.noteDescription});


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': noteName,
      'status': noteDescription,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int,
      noteName: map['noteName'] as String,
      noteDescription: map['noteDescription'] as String,
    );
  }
}
