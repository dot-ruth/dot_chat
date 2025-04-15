import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:dot_chat/providers/theme_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return  Column(
        children: [
         
            Expanded(
              flex: 3,
              child:  SingleChildScrollView(
                  child:  Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: 
                            Container(   
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                border: const GradientBoxBorder(
                                  gradient: LinearGradient(colors: [Colors.black, Colors.white]),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(themeProvider.themeMode == ThemeMode.dark ? 'assets/dot_dark.png' :'assets/dot.png', width: 50),
                                  const Text(
                                  "DOT",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Always Within Reach",
                                  style: TextStyle(fontSize: 18),
                                ),
                                ],
                              ),
                                
                            ),
                        ),
                          ],
                        ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                                      "Notifications",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                )
            ],
          ),
          SizedBox(
            height: 900,
            child: 
              ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
              ),
            
          ),
                        SizedBox(height: 20),
                      ],
                    ),
                ),
            ), 
        ],
      );
  }
}