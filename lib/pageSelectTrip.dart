import 'package:flutter/material.dart';

class PageSelectTrip extends StatefulWidget {
  PageSelectTrip({super.key});

  var progressText;

  @override
  State<PageSelectTrip> createState() => _PageStationsState();
}

class _PageStationsState extends State<PageSelectTrip> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() { 
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> column = [];

    return PopScope(
      canPop: false,
      child: MaterialApp(
        title: 'Movile',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 100, 181, 229),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const Center(child: Text(
                  'Movile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: "Parisine",
                    fontWeight: FontWeight.bold
                  ),
                ))
              ],
            )
          ),
          body: Column(
            children: column,
          )
        )
      )
    );
  }
}