import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:example/new_pages/header.dart';
import 'package:example/widgets/channel_list.dart';
import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:http/http.dart';

import '../routes/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with StreamChannelListEventHandler {
  late final _channelListController = StreamChannelListController(
      client: StreamChat.of(context).client,
      channelStateSort: [
        SortOption(
          'created_at',
          direction: SortOption.DESC,
        ),
      ],
      // filter: Filter.in_(
      //   'name',
      //   ['New group'],
      // ),
      presence: true,
      eventHandler: this);

  @override
  void initState() {
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (FirebaseAuth.instance.currentUser == null) {
        showDialog(
          context: context,
          builder: (context) {
            return SignInScreen(
              headerBuilder: (context, constraints, shrinkOffset) {
                return Container(
                    height: 100, color: Colors.purple, child: Center(child: Text('Persona')));
              },
              providers: [EmailAuthProvider()],
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  Navigator.of(context).pop();
                }),
              ],
            );
          },
        );
      } else {
        print('firebase signed in');

        channelsQuery.snapshots().listen((event) {
          for (var doc in event.docs) {
            var data = doc.data();
            channelsFromFirebase.add(data);

            // Create getstream channel (this is really a first-run thing)
            StreamChat.of(context).client.channel(
              'messaging',
              id: data['name'],
              extraData: {
                'name': data['name'],
                'image': data['image'],
                'userRoles': data['userRoles'],
                'publicCanChat': data['publicCanChat'],
                'communityID': data['communityID'] ?? 'personateam',
              },
            ).watch();
          }
        });
      }

      // NB: This needs to run after any run of the channelsQuery (in case we have new channels)
      communitiesTreasuriesQuery.snapshots().listen((event) {
        var data = event.data();
        if (data == null) return;

        var channelMap = data['channelMap'] as Map<String, dynamic>;

        channelMap.forEach((communityOrChannelID, data) {
          String channelID = communityOrChannelID == 'personateam' ? 'Home' : communityOrChannelID;
          var balance = data['available'];

          print('>>> setting balance for $channelID to $balance');
          StreamChat.of(context).client.channel('messaging', id: channelID).updatePartial(set: {
            'balance': balance,
          });
        });
      });
    });

    super.initState();
  }

  List<Map> channelsFromFirebase = [];

  ValueNotifier<Object?> fbQuery = ValueNotifier(null);

  var channelsQuery = FirebaseFirestore.instance
      .collection('personas')
      .where('communityID', isEqualTo: 'personateam')
      .where('name', isNotEqualTo: 'Unnamed Channel');

  var communitiesTreasuriesQuery =
      FirebaseFirestore.instance.collection('communityTreasuries').doc('personateam');

  var userAccountQuery =
      FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}');
  var userWalletQuery =
      FirebaseFirestore.instance.doc('userWallets/${FirebaseAuth.instance.currentUser!.uid}');

  @override
  void onChannelUpdated(Event event, StreamChannelListController controller) {
    //print(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
        body: Column(
          children: [
            // Center(
            //   child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [channelsQuery, userAccountQuery, userWalletQuery].map(
            //         (e) {
            //           return TextButton(
            //               onPressed: () {
            //                 fbQuery.value = e;
            //               },
            //               child: Text(e.toString()));
            //         },
            //       ).toList()),
            // ),
            // ValueListenableBuilder(
            //     valueListenable: fbQuery,
            //     builder: (context, value, _) {
            //       if (value == null) {
            //         return Container(
            //           height: 300,
            //           color: Colors.red[100],
            //           child: Center(child: Text('...')),
            //         );
            //       }
            //       return Container(
            //         height: 300,
            //         color: Colors.green[100],
            //         child: value is Query
            //             ? FirestoreListView<Map<String, dynamic>>(
            //                 query: value as Query<Map<String, dynamic>>,
            //                 itemBuilder: (context, snapshot) {
            //                   Map<String, dynamic> data = snapshot.data();

            //                   bool currentUserIsMember = data['userRoles']?['member']
            //                           ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
            //                       false;
            //                   bool channelHasPublicChat = data['publicCanChat'] ?? false;

            //                   if (channelHasPublicChat || currentUserIsMember) {
            //                     return Text(
            //                         'Channel name is ${data["name"]}, isMember: $currentUserIsMember isPublic: $channelHasPublicChat');
            //                   }
            //                   return Container();
            //                 },
            //               )
            //             : FutureBuilder(
            //                 future: (value as DocumentReference).get(),
            //                 builder: (context, snapshot) {
            //                   if (snapshot.hasData) {
            //                     Map<String, dynamic> data =
            //                         snapshot.data!.data() as Map<String, dynamic>;
            //                     return SingleChildScrollView(child: Text('User data is $data'));
            //                   }
            //                   return Text('Loading...');
            //                 },
            //               ),
            //       );
            //     }),
            // Container(
            //   height: 200,
            //   color: Colors.blue[100],
            //   child: PersonaSrvDataDump(path: '/payment/account/user'),
            // ),
            GroupFundHeader(channel: null),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: StreamChannelGridView(
                errorBuilder: (context, error) {
                  return Center(
                    child: Text(
                      'Error loading channels... {$error}}',
                      style: TextStyle(
                        color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
                      ),
                    ),
                  );
                },
                emptyBuilder: (context) {
                  return Center(
                    child: Text(
                      'No channels here...',
                      style: TextStyle(
                        color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
                      ),
                    ),
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.0,
                ),
                controller: _channelListController,
                itemBuilder: (context, items, index, defaultWidget) {
                  Channel channel = items[index];
                  return GestureDetector(
                    onTap: () {
                      //callFB();
                      GoRouter.of(context).pushNamed(
                        Routes.CHANNEL_PAGE.name,
                        pathParameters: Routes.CHANNEL_PAGE.params(items[index]),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: StreamChatTheme.of(context).colorTheme.borders, width: 1)),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Add red notification bubble in top right, that overlaps the border
                              // (use a random number for now, zero means no bubble)
                              BetterStreamBuilder(
                                  initialData: channel.state!.unreadCount,
                                  stream: channel.state!.unreadCountStream,
                                  builder: (context, snapshot) {
                                    return Positioned(
                                      top: -10,
                                      right: -10,
                                      child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(12)),
                                          child: Center(
                                            child: Text(
                                              snapshot.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          )),
                                    );
                                  }),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(items[index].name ?? '[no name]',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: gfTheme.textTheme.displaySmall
                                            ?.copyWith(fontSize: 20))),
                              ),
                              Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '\$${items[index].extraData['balance']?.toString() ?? '0'}',
                                    style: gfTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
                                  )),
                            ],
                          )),
                    ),
                  );
                },
              ),
            ))
          ],
        ));
  }
}

class PersonaSrvDataDump extends StatelessWidget {
  const PersonaSrvDataDump({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: personaSrvCall(path: path),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var response = snapshot.data as Response;
          return SingleChildScrollView(child: Text('Data for ($path) is ${response.body}'));
        }
        return Text('Loading...');
      },
    );
  }
}

void callFB() {
  try {
    FirebaseFunctions.instance.httpsCallable('helloWorld').call().then(
      (value) {
        print(value.data);
      },
    );
  } catch (e) {
    print(e);
  }
}

Future<Response> personaSrvCall(
    {required String path, Map<String, dynamic> params = const {}}) async {
  String personaApiHost = 'api-v0.persona.nyc';
  String? userToken = await FirebaseAuth.instance.currentUser!.getIdToken();

  return get(Uri.https(personaApiHost, path, params), headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $userToken',
  });
}
