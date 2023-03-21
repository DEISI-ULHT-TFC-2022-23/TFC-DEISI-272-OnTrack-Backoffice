import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrack_backoffice/controllers/api_requests.dart';
import 'package:ontrack_backoffice/controllers/controllers.dart';
import 'package:ontrack_backoffice/static/colors.dart';
import 'package:http/http.dart' as http;
import 'package:ontrack_backoffice/widgets/home_page/medium_screen/calendario.dart';

class HomePageAPI extends StatelessWidget {
  const HomePageAPI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              children: [
                Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                SizedBox(height: 40,),

                // Container de UCs e Eventos de Avaliação
                //TODO: Porque é que est+a a dar RenderFlex overflowed?
                Row(
                  children: [
                    //UCs
                    buildUCsContainer(context),

                    //Eventos de Avaliação
                    buildListaEventosAvaliacao(context),
                  ],
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 40,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                //TODO: Pesquisar sobre o Flexible

                // Parte de baixo com o calendário e os detalhes do dia
                Flexible(
                  child: Calendario()
                )
              ],
            ),
          )
      ),
    );
  }


  Container buildUCsContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.4,

      child: FutureBuilder(
        future: getUCByProfID(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.start,
                children: snapshot.data as List<Widget>,
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Expanded buildListaEventosAvaliacao(BuildContext context) {
    return Expanded(
      child: Container(
        //color: Colors.red[600],
        height: MediaQuery.of(context).size.height * 0.4,
        child: Center(
            child: Stack(
              children: [
                //Container de fundo
                Container(
                  //Altura do Positioned
                  margin: EdgeInsets.only(top: 40),
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  //Container do ListView
                  child: SizedBox.expand(
                    child: Container(
                        //color: Colors.deepOrange,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            children: [
                              FutureBuilder(
                                future: getEventosProfID(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Wrap(
                                        runSpacing: 10,
                                        alignment: WrapAlignment.start,
                                        children: snapshot.data as List<Widget>,
                                      ),
                                    );
                                  } else {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ),
                  ),
                ),
                //Container do topo com o título
                Positioned(
                  // center positioned
                  child: Container(
                    decoration: BoxDecoration(
                      color: loginButtonColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    height: 40,
                    width: double.infinity,
                      child: Center(child: Text('Eventos de Avaliação', style: TextStyle(color: Colors.white, fontSize: 17),))
                  )
                )
              ]
            )
        ),
      ),
    );
  }

  Container buildCalendario(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      height: MediaQuery.of(context).size.height * 0.34,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          //Título
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              //color: Colors.orange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
                child: Text(
                  getMonth(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
            ),
          ),
          //Calendário
          Container(
            height: MediaQuery.of(context).size.height * 0.34 - 40,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              //color: Colors.lightGreenAccent,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: GridView.count(
              padding: EdgeInsets.all(10),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 10,
              children: getCalendarDays(),
            )
          ),
        ],
      ),
    );
  }
  String getMonth(){
    return capitalize(DateFormat('MMMM','pt').format(DateTime.now()));
  }
  String capitalize(String str) {
    return str.replaceRange(0, 1, str[0].toUpperCase());
  }

  List<Widget> getCalendarDays() {
    List<Widget> calendarDays = [];
    for (int i = 1; i <= getNumberOfDaysMonth(); i++) {
      calendarDays.add(
        InkWell(
          onTap: () {
            // Vai mostrar o container dos detalhes do dia do calendário
            print('Dia $i');
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(i.toString())),
          ),
        ),
      );
    }
    return calendarDays;
  }

  int getNumberOfDaysMonth(){

     final month = DateTime.now().month.toString();

     if(month =='1' || month =='3' || month =='5' || month =='7' || month =='8' || month =='10' || month =='12'){
       return 31;
      }else if(month =='4' || month =='6' || month =='9' || month =='11'){
       return 30;
      }else{
        return 28;
      }
  }
}
