import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _imagem;
  Image _imagem2;
  String _statusUpload = "Upload não iniciado...";
  String _urlImagemRecuperada = null;

  final picker = ImagePicker();

  Future _recuperarImagem(bool daCamera) async {
    PickedFile pickedFile;
    String img64;

    if (daCamera) {
      pickedFile = await picker.getImage(source: ImageSource.camera);
    } else {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    }

    //*********************************
    //Encode base 64
    final bytes = File(pickedFile.path).readAsBytesSync();
    img64 = base64Encode(bytes);
    //Encode base 64 - fim
    //*********************************

    //decode base 64
    final decodedBytes = base64Decode(img64);
    _imagem2 = Image.memory(decodedBytes, height: 200, width: 200);

//    Firestore.instance
//        .collection("imagem64")
//        .document("002")
//        .setData({"decodedBytes": decodedBytes.toString()});

//      _imagem2 = File("imagem.jpg");
//      _imagem2.writeAsBytesSync(decodedBytes);

    //decode base 64 fim
    Firestore.instance
        .collection("imagem64")
        .document("001")
        .setData({"imagem64": img64});

    setState(() {
      if (pickedFile != null) {
        _imagem =
            File(pickedFile.path); //forma original de pegar direto da camera
      } else {
        print(' #################### No image selected.');
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;

    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child("fotos").child("gtr.jpg");

    StorageUploadTask task = arquivo.putFile(_imagem);

    task.events.listen((event) {
      if (event.type == StorageTaskEventType.progress) {
        setState(() {
          this._statusUpload = "Upload em progresso...";
        });
      } else if (event.type == StorageTaskEventType.success) {
        setState(() {
          this._statusUpload = "Upload realizado com sucesso!";
        });
      }
      ;
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    print("URL STORAGE FIRE BASE : " + url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecionar Imagem"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(_statusUpload),
            RaisedButton(
              onPressed: () {
                _recuperarImagem(true);
              },
              child: Text("Abrir Câmera"),
            ),
            RaisedButton(
              onPressed: () {
                _recuperarImagem(false);
              },
              child: Text("Abrir Galeria"),
            ),
            _imagem == null
                ? Text("Sem imagem selecionada")
                : Image.file(
                    _imagem,
                    width: 200,
                    height: 200,
                  ),
            _imagem2 == null ? Text("SEM IMAGEM 2") : _imagem2,
            _imagem == null
                ? Container()
                : RaisedButton(
                    onPressed: () {
                      _uploadImagem();
                    },
                    child: Text("Upload Imagem"),
                  ),
            _urlImagemRecuperada == null
                ? Container()
                : Image.network(_urlImagemRecuperada)
          ],
        ),
      ),
    );
  }
}

//***** COLINHA KKK

//WidgetsFlutterBinding.ensureInitialized();

//Firestore.instance
//    .collection("usuarios")
//  .document("nascimento")
//  .setData({"edu": "1990", "pai": "1968", "mae": "1970"});

//INSTANTE
//Firestore db = Firestore.instance;
//  INSERT
//  db.collection("usuarios").document("002").setData({
//    "nome":"Cirlene",
//    "idade":"51"
//  });

//    UPDATE SÓ MANDAR NO MESMO DOCUMENTO
//  db.collection("usuarios").document("002").setData({
//    "nome":"Cirlene Anastácio Solis",
//    "idade":"51"
//  });

//db.collection("usuarios").document("002").delete();

//  Recupera um documento especifico
//  DocumentSnapshot snapshot = await db.collection("usuarios").document("001").get();
//  print("dados : " + snapshot.data.toString());

//retornando todos os dados da collection "usuarios"
//   QuerySnapshot querySnapshot = await db.collection("usuarios").getDocuments();
//   for(DocumentSnapshot item in querySnapshot.documents){
//     var dados = item.data;
//     print("Toda coleçãode usuario ->  Nome: " + item["nome"] + '  todos os dados -> ' + dados.toString());
//   }

//buscar lista de dados sempre que houver mudança no banco de dados
//usamos o Listen (adiciona um ouvinte, o fire base notifica)
//  db.collection("usuarios").snapshots().listen((event) {
//
//    for (DocumentSnapshot item in event.documents) {
//      var dados = item.data;
//      print("Toda coleçãode usuario ->  Nome: " +
//          item["nome"] +
//          '  todos os dados -> ' +
//          dados.toString());
//    }
//  });

//CRIACAO DE USUÁRIO
//  auth.createUserWithEmailAndPassword(email: email, password: senha)
//      .then((fireBaseUser) => {
//        print("novo usuário: sucesso!! email: " + fireBaseUser.email)
//      }).catchError((erro){
//        print("novo usuário erro: " + erro.toString());
//  });

//VERIFICAR SE O USUÁRIO ESTÁ LOGADO
//FirebaseUser usuarioAtual = await auth.currentUser();
//
//if (usuarioAtual != null ) {
////LOGADO
//print("usuário logado email: " + usuarioAtual.email);
//}else {
//print("usuário DESLOGADO");
//}

//DESLOGAR USUARIO
//auth.singOut();

//Processo de SingIn (LogIn)
//auth.signInWithEmailAndPassword(
//email: email,
//password: senha
//).then((value) => {
//print("usuário logou email: " + value.email)
//}).catchError((onError){
//print("usuário erro: " + onError.toString());
//});
