import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'home_page.dart';

class GroupFundHeader extends StatelessWidget {
  const GroupFundHeader({
    super.key,
    required this.channel,
    this.onTapBack,
  });

  final Channel? channel;
  final Function? onTapBack;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedOpacity(
            opacity: channel == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(top: 70.0, left: 40),
              child: GestureDetector(
                onTap: onTapBack as void Function()?,
                child: Text(
                  channel == null ? '' : '< Persona',
                  style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 40),
            child: Text(
              channel == null ? 'Persona' : channel?.name ?? '[no name]',
              style: gfTheme.textTheme.displayLarge,
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 40),
              child: StreamBuilder<Object>(
                  stream: channel?.extraDataStream,
                  initialData: null,
                  builder: (context, snapshot) {
                    num? balance = snapshot.hasData ? (snapshot.data! as Map)['balance'] : null;
                    return Text('\$${balance?.toString() ?? 0}',
                        style: gfTheme.textTheme.displayMedium);
                  })),
          Padding(
            padding: const EdgeInsets.only(left: 34.0),
            child: ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                MainButton(
                  color: Color.fromARGB(255, 94, 194, 97),
                  text: '+ Add money',
                  fontSize: 20,
                ),
                MainButton(
                  color: Color.fromARGB(255, 88, 172, 202),
                  text: 'Withdraw',
                  fontSize: 20,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34.0),
            child: ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                MainButton(
                  color: Color.fromARGB(255, 212, 169, 255),
                  text: '+ Invite',
                  fontSize: 16,
                ),
                if (channel == null)
                  MainButton(
                    color: Color.fromARGB(255, 212, 169, 255),
                    text: '+ Create group',
                    fontSize: 16,
                    onPressed: () => callFB(),
                  )
              ],
            ),
          ),
        ]);
  }
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.color,
    required this.text,
    this.onPressed,
    required this.fontSize,
  });

  final Color color;
  final String text;
  final Function? onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        // Rounded border
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), side: BorderSide(color: color)))),
        onPressed: onPressed as void Function()?,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(text,
              style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600)),
        ));
  }
}

Future<dynamic> showNewGroupModal(BuildContext context) {
  return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom), // Accommodates for the keyboard
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New group',
                      style: TextStyle(
                          fontFamily: 'Avenir',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700])),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Group name',
                    ),
                  ),
                  MainButton(
                      color: Colors.blue,
                      text: 'Create',
                      fontSize: 16,
                      onPressed: () {
                        StreamChat.of(context)
                            .client
                            .channel('messaging',
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                extraData: {
                                  'name':
                                      'New group ${DateTime.now().millisecondsSinceEpoch % 1000}',
                                  'balance': 134.0
                                })
                            .watch()
                            .then((state) {
                              print('refresh');
                              // Then we can refresh the UI
                              Navigator.pop(context);
                            });
                      })
                ],
              ),
            ),
          ),
        );
      });
}

final ThemeData gfTheme = ThemeData(
  fontFamily: 'Avenir',
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey[700]),
    displayMedium: TextStyle(
        fontSize: 36, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 94, 194, 97)),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
  ),
);

final ColorScheme gfColorScheme = ColorScheme.light(
  primary: const Color.fromARGB(255, 94, 194, 97),
  secondary: const Color.fromARGB(255, 212, 169, 255),
  tertiary: const Color.fromARGB(255, 88, 172, 202),
  background: Colors.white,
);
