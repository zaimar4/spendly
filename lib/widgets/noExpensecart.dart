import 'package:flutter/material.dart';

class Noexpensecart extends StatelessWidget {
  final String judul;
  final String subjudul;
  const Noexpensecart({super.key,
  required this.judul,
  required this.subjudul
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 350,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:Colors.grey.withOpacity(0.6),
            blurRadius: 2,
            offset: Offset(0, 1)
          ),
        ],
         color : Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color.fromARGB(255, 235, 236, 237),
                    child: Icon(Icons.wallet,color:Color.fromARGB(255, 132, 130, 130),size: 30,),
                  ),
          SizedBox(height: 10,),
          Text(judul,
          style:  TextStyle(
             fontSize: 18,
              color: Colors.grey
          ),
          ),
          SizedBox(height: 10,),
          Text(subjudul,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey
          ),)
        ],
      ),
    );
  }
}
