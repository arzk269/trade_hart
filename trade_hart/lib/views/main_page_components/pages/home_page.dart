import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/feed_provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/search_filter_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/home_feed.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/search_view_components/filter_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/search_view_components/search_field.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_divider.dart';
import 'package:trade_hart/views/main_page_components/pages/filters_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
    //     stream: FirebaseFirestore.instance.collection('Users').snapshots(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError) {
    //         return Center(child: Text('Erreur: ${snapshot.error}'));
    //       }

    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    return SingleChildScrollView(
      child: Column(
        children: [
          // SEARCH
          Row(
            children: [
              const SearchField(),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FilterPage(
                            categories: context.read<FeedPovider>().eshop
                                ? articlesFilters
                                : serviceFilters))),
                child: const FilterButton(),
              )
            ],
          ),

          //Selection
          SizedBox(height: manageHeight(context, 13)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SelectionButton(
                selection: "e-shop",
                changeSelection: () {
                  setState(() {
                    context.read<FeedPovider>().changeSelection();
                  });
                },
                buttonColor: context.read<FeedPovider>().eshop
                    ? AppColors.mainColor
                    : Colors.white,
                textColor: context.read<FeedPovider>().eshop
                    ? Colors.white
                    : AppColors.mainColor,
              ),
              const SelectionDivider(),
              SelectionButton(
                selection: "services",
                changeSelection: () {
                  setState(() {
                    context.read<FeedPovider>().changeSelection2();
                  });
                },
                buttonColor: context.read<FeedPovider>().eshop
                    ? Colors.white
                    : AppColors.mainColor,
                textColor: context.read<FeedPovider>().eshop
                    ? AppColors.mainColor
                    : Colors.white,
              ),
            ],
          ),

          SizedBox(
            height: manageHeight(context, 10),
          ),
          Consumer<SearchFilterProvider>(
            builder: (context, value, child) => Container(
              margin: EdgeInsets.only(left: manageWidth(context, 10)),
              height: context.read<FeedPovider>().eshop
                  ? value.articlesFilters.isEmpty
                      ? 1
                      : manageHeight(context, 45)
                  : value.servicesFilters.isEmpty
                      ? 1
                      : manageHeight(context, 45),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: (context.read<FeedPovider>().eshop &&
                            value.articlesFilters.isEmpty) ||
                        (!context.read<FeedPovider>().eshop &&
                            value.servicesFilters.isEmpty)
                    ? [const SizedBox()]
                    : context.read<FeedPovider>().eshop
                        ? value.articlesFilters
                            .map((e) => Container(
                                  padding: EdgeInsets.only(
                                      left: manageWidth(context, 10),
                                      right: manageWidth(context, 10)),
                                  margin: EdgeInsets.fromLTRB(
                                      manageWidth(context, 5),
                                      manageHeight(context, 5),
                                      manageWidth(context, 5),
                                      manageHeight(context, 5)),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 180, 92, 159),
                                        width: manageWidth(context,
                                            1.0), // Épaisseur des bordures
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 15))),
                                  child: Center(
                                      child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          value.removeFromArticlesFilters(e);
                                        },
                                        child: Icon(CupertinoIcons.clear,
                                            size: manageWidth(context, 18),
                                            color: const Color.fromARGB(
                                                255, 180, 92, 159)),
                                      ),
                                      SizedBox(
                                        width: manageWidth(context, 3),
                                      ),
                                      Text(
                                        e,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize: manageWidth(context, 15),
                                            color: const Color.fromARGB(
                                                255, 180, 92, 159)),
                                      ),
                                    ],
                                  )),
                                ))
                            .toList()
                        : value.servicesFilters
                            .map((e) => Container(
                                  padding: EdgeInsets.only(
                                      left: manageWidth(context, 10),
                                      right: manageWidth(context, 10)),
                                  margin: EdgeInsets.fromLTRB(
                                      manageWidth(context, 5),
                                      manageHeight(context, 5),
                                      manageWidth(context, 5),
                                      manageHeight(context, 5)),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 180, 92, 159),
                                        width: manageWidth(context,
                                            1.0), // Épaisseur des bordures
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 15))),
                                  child: Center(
                                      child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          value.removeFromServicesFilters(e);
                                        },
                                        child: Icon(CupertinoIcons.clear,
                                            size: manageWidth(context, 18),
                                            color: const Color.fromARGB(
                                                255, 180, 92, 159)),
                                      ),
                                      SizedBox(
                                        width: manageWidth(context, 3),
                                      ),
                                      Text(
                                        e,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize: manageWidth(context, 15),
                                            color: const Color.fromARGB(
                                                255, 180, 92, 159)),
                                      ),
                                    ],
                                  )),
                                ))
                            .toList(),
              ),
            ),
          ),
          Container(
            height: manageHeight(context, 480),
            width: MediaQuery.of(context).size.width * 0.96,
            margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5),
                manageHeight(context, 13), manageWidth(context, 7.5), 0),
            padding: EdgeInsets.fromLTRB(
                manageWidth(context, 5),
                manageHeight(context, 5),
                manageWidth(context, 5),
                manageHeight(context, 5)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: manageWidth(context, 0.1),
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: manageHeight(context, 1.5),
                  blurRadius: manageHeight(context, 5),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IndexedStack(
              index: context.read<FeedPovider>().eshop ? 0 : 1,
              children: feed,
            ),
          )
        ],
      ),
    );

    //   return Expanded(
    //       child: ListView.builder(
    //           itemCount: snapshot.data!.docs.length,
    //           itemBuilder: (context, index) {
    //             var users = snapshot.data!.docs;
    //             return TextButton(
    //               child: Text(users[index]["name"]),
    //               onPressed: () async {
    //                 String currentUserId =
    //                     FirebaseAuth.instance.currentUser!.uid;
    //                 // Rechercher une conversation existante entre les deux utilisateurs
    //                 var existingConversations1 = await FirebaseFirestore
    //                     .instance
    //                     .collection('Conversations')
    //                     .where(
    //                   'users',
    //                   isEqualTo: [currentUserId, users[index].id],
    //                 ).get();

    //                 var existingData1 = existingConversations1.docs;

    //                 var existingConversations2 = await FirebaseFirestore
    //                     .instance
    //                     .collection('Conversations')
    //                     .where(
    //                   'users',
    //                   isEqualTo: [users[index].id, currentUserId],
    //                 ).get();

    //                 var existingData2 = existingConversations2.docs;

    //                 //Si une conversation existe, naviguer vers la page de conversation avec l'ID de la conversation
    //                 if (existingData1.isNotEmpty ||
    //                     existingData2.isNotEmpty) {
    //                   if (existingData1.isNotEmpty) {
    //                     String conversationId = existingData1[0].id;
    //                     //ignore: use_build_context_synchronously
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                           builder: (context) => ConversationPage(
    //                                 conversationId: conversationId,
    //                                 memberId: users[index].id,
    //                               )),
    //                     );
    //                   } else {
    //                     String conversationId = existingData2[0].id;
    //                     //ignore: use_build_context_synchronously
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                           builder: (context) => ConversationPage(
    //                                 conversationId: conversationId,
    //                                 memberId: users[index].id,
    //                               )),
    //                     );
    //                   }
    //                 } else {
    //                   // Si aucune conversation n'existe , créer une nouvelle conversation
    //                   DocumentReference newConversationRef =
    //                       await FirebaseFirestore.instance
    //                           .collection('Conversations')
    //                           .add({
    //                     'users': [currentUserId, users[index].id],
    //                     'last message': "",
    //                     'last time': Timestamp.now(),
    //                     "is all read": {"sender": true, "receiver": false}
    //                   });
    //                   String conversationId = newConversationRef.id;
    //                   //  ignore: use_build_context_synchronously
    //                   Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (context) => ConversationPage(
    //                               conversationId: conversationId,
    //                               memberId: users[index].id,
    //                             )),
    //                   );
    //                 }
    //               },
    //             );
    //           }));
    // });
  }
}
