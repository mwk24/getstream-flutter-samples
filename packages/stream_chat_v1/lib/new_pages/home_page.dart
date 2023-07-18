import 'package:cloud_functions/cloud_functions.dart';
import 'package:example/new_pages/header.dart';
import 'package:example/widgets/channel_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

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
  void onChannelUpdated(Event event, StreamChannelListController controller) {
    print(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
        body: Column(
          children: [
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
                      callFB();
                      // GoRouter.of(context).pushNamed(
                      //   Routes.CHANNEL_PAGE.name,
                      //   pathParameters: Routes.CHANNEL_PAGE.params(items[index]),
                      // );
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
