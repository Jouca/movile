import 'package:flutter/material.dart';
import 'package:movile/extensions.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Lines {
  List<Line> lines = [];

  List<Line> getLines() {
    return lines;
  }

  void parseLines(List<dynamic> data) {
    for (var i = 1; i < data.length; i++) {
      // check if route_id && agency_id && route_short_name && route_long_name is not already in the list
      if (lines.indexWhere((element) => element.route_id == data[i][0] && element.agency_id == data[i][1] && element.route_short_name == data[i][2] && element.route_long_name == data[i][3]) == -1) {
        lines.add(Line(
          route_id: data[i][0],
          agency_id: data[i][1],
          route_short_name: data[i][2],
          route_long_name: data[i][3],
          route_desc: data[i][4],
          route_type: data[i][5],
          route_url: data[i][6],
          route_color: data[i][7],
          route_text_color: data[i][8],
          route_sort_order: data[i][9],
        ));
      }
    }

    // Order line based on route_type on that order (1, 2, 0, 4) and route_short_name and also of the length of route_short_name
    lines.sort((a, b) {
      if (a.route_type == b.route_type) {
        if (a.route_short_name!.length == b.route_short_name!.length) {
          return a.route_short_name!.compareTo(b.route_short_name!);
        }
        return a.route_short_name!.length.compareTo(b.route_short_name!.length);
      }
      return a.route_type!.compareTo(b.route_type!);
    });
  }

  /*void filterSearchResults(String query) {
    List<Line> searchResult = [];
    searchResult.addAll(lines);
    if (query.isNotEmpty) {
      List<Line> dummyListData = [];
      lines.clear();
      searchResult.forEach((item) {
        if (item.route_short_name!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      dummyListData.sort((a, b) {
        if (a.route_type == b.route_type) {
          return a.route_short_name!.compareTo(b.route_short_name!);
        }
        return a.route_type!.compareTo(b.route_type!);
      });

      lines.clear();
      lines.addAll(dummyListData);
    } else {
      lines.clear();
      lines.addAll(searchResult);
    }
  }*/
}

class Line {
  String? route_id;
  String? agency_id;
  String? route_short_name;
  String? route_long_name;
  String? route_desc;
  String? route_type;
  String? route_url;
  String? route_color;
  String? route_text_color;
  String? route_sort_order;

  Line({
    this.route_id,
    this.agency_id,
    this.route_short_name,
    this.route_long_name,
    this.route_desc,
    this.route_type,
    this.route_url,
    this.route_color,
    this.route_text_color,
    this.route_sort_order,
  });

  Widget? getIDFMLogo(scale) {
    switch(route_id) {
      // Trams
      case "IDFM:C01389":
        return Image.asset("assets/images/lines/tram_T1_fc_RVB.png", scale: scale);
      case "IDFM:C01390":
        return Image.asset("assets/images/lines/tram_T2_fc_RVB.png", scale: scale);
      case "IDFM:C01391":
        return Image.asset("assets/images/lines/tram_T3a_fc_RVB.png", scale: scale);
      case "IDFM:C01679":
        return Image.asset("assets/images/lines/tram_T3b_fc_RVB.png", scale: scale);
      case "IDFM:C01843":
        return Image.asset("assets/images/lines/tram_T4_fc_RVB.png", scale: scale);
      case "IDFM:C01684":
        return Image.asset("assets/images/lines/tram_T5_fc_RVB.png", scale: scale);
      case "IDFM:C01794":
        return Image.asset("assets/images/lines/tram_T6_fc_RVB.png", scale: scale);
      case "IDFM:C01774":
        return Image.asset("assets/images/lines/tram_T7_fc_RVB.png", scale: scale);
      case "IDFM:C01795":
        return Image.asset("assets/images/lines/tram_T8_fc_RVB.png", scale: scale);
      case "IDFM:C02317":
        return Image.asset("assets/images/lines/tram_T9_fc_RVB.png", scale: scale);
      case "IDFM:C02528":
        return Image.asset("assets/images/lines/tram_T10_fc_RVB.png", scale: scale);
      case "IDFM:C01999":
        return Image.asset("assets/images/lines/tram_T11_fc_RVB.png", scale: scale);
      case "IDFM:C02529":
        return Image.asset("assets/images/lines/tram_T12_fc_RVB.png", scale: scale);
      case "IDFM:C02344":
        return Image.asset("assets/images/lines/tram_T13_fc_RVB.png", scale: scale);

      // Metros
      case "IDFM:C01371":
        return Image.asset("assets/images/lines/metro_1_fc_RVB.png", scale: scale);
      case "IDFM:C01372":
        return Image.asset("assets/images/lines/metro_2_fc_RVB.png", scale: scale);
      case "IDFM:C01373":
        return Image.asset("assets/images/lines/metro_3_fc_RVB.png", scale: scale);
      case "IDFM:C01386":
        return Image.asset("assets/images/lines/metro_3bis_fc_RVB.png", scale: scale);
      case "IDFM:C01374":
        return Image.asset("assets/images/lines/metro_4_fc_RVB.png", scale: scale);
      case "IDFM:C01375":
        return Image.asset("assets/images/lines/metro_5_fc_RVB.png", scale: scale);
      case "IDFM:C01376":
        return Image.asset("assets/images/lines/metro_6_fc_RVB.png", scale: scale);
      case "IDFM:C01377":
        return Image.asset("assets/images/lines/metro_7_fc_RVB.png", scale: scale);
      case "IDFM:C01387":
        return Image.asset("assets/images/lines/metro_7bis_fc_RVB.png", scale: scale);
      case "IDFM:C01378":
        return Image.asset("assets/images/lines/metro_8_fc_RVB.png", scale: scale);
      case "IDFM:C01379":
        return Image.asset("assets/images/lines/metro_9_fc_RVB.png", scale: scale);
      case "IDFM:C01380":
        return Image.asset("assets/images/lines/metro_10_fc_RVB.png", scale: scale);
      case "IDFM:C01381":
        return Image.asset("assets/images/lines/metro_11_fc_RVB.png", scale: scale);
      case "IDFM:C01382":
        return Image.asset("assets/images/lines/metro_12_fc_RVB.png", scale: scale);
      case "IDFM:C01383":
        return Image.asset("assets/images/lines/metro_13_fc_RVB.png", scale: scale);
      case "IDFM:C01384":
        return Image.asset("assets/images/lines/metro_14_fc_RVB.png", scale: scale);

      // RERs
      case "IDFM:C01742":
        return Image.asset("assets/images/lines/RER_A_fc_RVB.png", scale: scale);
      case "IDFM:C01743":
        return Image.asset("assets/images/lines/RER_B_fc_RVB.png", scale: scale);
      case "IDFM:C01727":
        return Image.asset("assets/images/lines/RER_C_fc_RVB.png", scale: scale);
      case "IDFM:C01728":
        return Image.asset("assets/images/lines/RER_D_fc_RVB.png", scale: scale);
      case "IDFM:C01729":
        return Image.asset("assets/images/lines/RER_E_fc_RVB.png", scale: scale);

      // Transiliens
      case "IDFM:C01737":
        return Image.asset("assets/images/lines/train_H_fc_RVB.png", scale: scale);
      case "IDFM:C01739":
        return Image.asset("assets/images/lines/train_J_fc_RVB.png", scale: scale);
      case "IDFM:C01738":
        return Image.asset("assets/images/lines/train_K_fc_RVB.png", scale: scale);
      case "IDFM:C01740":
        return Image.asset("assets/images/lines/train_L_fc_RVB.png", scale: scale);
      case "IDFM:C01736":
        return Image.asset("assets/images/lines/train_N_fc_RVB.png", scale: scale);
      case "IDFM:C01730":
        return Image.asset("assets/images/lines/train_P_fc_RVB.png", scale: scale);
      case "IDFM:C01731":
        return Image.asset("assets/images/lines/train_R_fc_RVB.png", scale: scale);
      case "IDFM:C01741":
        return Image.asset("assets/images/lines/train_U_fc_RVB.png", scale: scale);
      default:
        return null;
    }
  }

  Image getRERORTransilienLogo(String? route_short_name, scale) {
    List<String> RER = ["A", "B", "C", "D", "E"];
    if (RER.contains(route_short_name)) {
      return Image.asset("assets/images/transport_modes/symbole_RER_fc_RVB.png", scale: scale);
    } else {
      return Image.asset("assets/images/transport_modes/symbole_train_fc_RVB.png", scale: scale);
    }
  }

  Container getLineIcon(double scale) {
    switch (route_type) {
      case "0":
        List<Widget> childrenLogo = [
          Image.asset("assets/images/transport_modes/symbole_tram_fc_RVB.png", scale: scale),
        ];
        var idfmlogo = getIDFMLogo(scale);
        if (idfmlogo != null) {
          childrenLogo.add(idfmlogo);
        }

        return Container(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 70 * scale,
            height: 30 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: childrenLogo
            )
          )
        );
      case "1":
        List<Widget> childrenLogo = [
          Image.asset("assets/images/transport_modes/symbole_metro_fc_RVB.png", scale: scale),
        ];
        var idfmlogo = getIDFMLogo(scale);
        if (idfmlogo != null) {
          childrenLogo.add(idfmlogo);
        }
        return Container(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 70 * scale,
            height: 30 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: childrenLogo
            )
          )
        );
      case "2":
        List<Widget> childrenLogo = [
          getRERORTransilienLogo(route_short_name, scale),
        ];
        var idfmlogo = getIDFMLogo(scale);
        if (idfmlogo != null) {
          childrenLogo.add(idfmlogo);
        }
        return Container(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 70 * scale,
            height: 30 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: childrenLogo
            )
          )
        );
      case "3":
        List<Widget> childrenLogo = [
          Image.asset("assets/images/transport_modes/symbole_bus_fc_RVB.png", scale: scale)
        ];
        var idfmlogo = getIDFMLogo(scale);
        if (idfmlogo != null) {
          childrenLogo.add(idfmlogo);
        } else {
          childrenLogo.add(getBusIcon(scale));
        }
        return Container(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 110 * scale,
            height: 30 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: childrenLogo
            )
          )
        );
      default:
        List<Widget> childrenLogo = [
          Image.asset("assets/images/transport_modes/symbole_bus_fc_RVB.png", scale: scale)
        ];
        var idfmlogo = getIDFMLogo(scale);
        if (idfmlogo != null) {
          childrenLogo.add(idfmlogo);
        } else {
          childrenLogo.add(getBusIcon(scale));
        }
        return Container(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            width: 110 * scale,
            height: 30 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: childrenLogo
            )
          )
        );
    }
  }

  Container getBusIcon(double scale) {
    var text_color = route_text_color;
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5),
      color: "#$route_color".toColor(),
      child: AutoSizeText(
        route_short_name!,
        textAlign: TextAlign.center,
        minFontSize: 10 * scale,
        maxFontSize: 20 * scale,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: "#$text_color".toColor()
        )
      )
    );
  }

  String getTransportTypeName() {
    switch (route_type) {
      case "0":
        return "Tramway";
      case "1":
        return "Métro";
      case "2":
        switch(route_id) {
          case "IDFM:C01742":
            return "RER";
          case "IDFM:C01743":
            return "RER";
          case "IDFM:C01727":
            return "RER";
          case "IDFM:C01728":
            return "RER";
          case "IDFM:C01729":
            return "RER";
          case "IDFM:C01737":
            return "Transilien";
          case "IDFM:C01739":
            return "Transilien";
          case "IDFM:C01738":
            return "Transilien";
          case "IDFM:C01740":
            return "Transilien";
          case "IDFM:C01736":
            return "Transilien";
          case "IDFM:C01730":
            return "Transilien";
          case "IDFM:C01731":
            return "Transilien";
          case "IDFM:C01741":
            return "Transilien";
          default:
            return "Train";
        }
      case "3":
        return "Bus";
      default:
        return "Bus";
    }
  }
}