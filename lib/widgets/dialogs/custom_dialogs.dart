import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

//Contiene diálogos que se van a reutilizar
void buildCustomDialogWithImage(BuildContext context, String localImagePath, String title, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sin bordes redondeados
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    localImagePath,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      text,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CERRAR', style: TextStyle(color: Colors.lightBlue, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLottieDialog(BuildContext context, String title, String content, String lottie){
    return AlertDialog(
      title: Text(title),
      content: Lottie.asset("assets/animations/error.json", repeat: false, height: 120),
      actions: [
        TextButton(
          onPressed: () =>{
            Navigator.pop(context),
            Navigator.pop(context), 
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  Widget buildCustomErrorDialog(BuildContext context, String title, String content, int popClose){
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/animations/error.json", repeat: false, height: 120),
          const SizedBox(height: 8,),
          Text(
            content,
            textAlign: TextAlign.justify,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>{
            for(int i = 0; i < popClose; i++){
              Navigator.pop(context)
            }
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  Widget buildCustomInfoDialog(BuildContext context, String title, String content, int popClose){
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/animations/info.json", repeat: false, height: 120),
          const SizedBox(height: 8,),
          Text(
            content,
            textAlign: TextAlign.justify,
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>{
            for(int i = 0; i < popClose; i++){
              Navigator.pop(context)
            }
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }

  Widget buildCustomSuccessDialog(BuildContext context, String title, int popClose, [String? content]){
    return AlertDialog(
      title: Text(title),
      content: content == null
        ? Lottie.asset("assets/animations/success.json", repeat: false, height: 120)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset("assets/animations/success.json", repeat: false, height: 120),
              const SizedBox(height: 8),
              Text(
                content,
                textAlign: TextAlign.justify,
              )
            ],
          ),
      actions: [
        TextButton(
          onPressed: () =>{
            for(int i = 0; i < popClose; i++){
              Navigator.pop(context)
            }
          },
          child: const Text("Cerrar", style: TextStyle(color: Colors.lightBlue, fontSize: 15))
        )
      ],
    );
  }
