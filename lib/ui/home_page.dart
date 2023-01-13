import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gif_searcher/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

const url_trending = 'https://api.giphy.com/v1/gifs/trending?api_key=H7LmR4yZaHrDDvZF9HHu4XXdpcFK3eYn&limit=20&rating=g';
const appbar_image = 'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? search;
  int offset = 0;

  @override
  void initState(){
    super.initState();
    getGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 30,
        backgroundColor: Colors.black,
        title: Image.network(appbar_image),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                )
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              onSubmitted: (text){
                setState((){
                  search = text;
                  offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if(snapshot.hasError){
                      return Container();
                    } else {
                      return createGifTable(context, snapshot);
                    }
                }
              }
            )
          )
        ],
      ),
    );
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot){
    List<dynamic> itens = snapshot.data['data'];
    int count = itens.length;

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ), 
      itemCount: getCount(snapshot.data['data']),
      itemBuilder: (context, index){
        if(search == null || index < count) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => GifPage(gifData: snapshot.data['data'][index])));
            },
            onLongPress: (){
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  'Carregar mais',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            onTap: (){
              setState(() {
                offset += 19;
              });
            },
          );
        }
      }
    );
  }
  
  int getCount(List data){
    if (search == null || search!.isEmpty){
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Future<Map> getGifs() async {
    http.Response response;

    if(search == null || search!.isEmpty){
      response = await http.get(Uri.parse(url_trending));
    } else {
      response = await http.get(Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=H7LmR4yZaHrDDvZF9HHu4XXdpcFK3eYn&q=$search&limit=19&offset=$offset&rating=g&lang=pt'));
    }

    return json.decode(response.body);
  }
}
