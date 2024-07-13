import 'package:Thilogi/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';
import '../blocs/user_bloc.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyAccount(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class CustomBodyAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyAccountScreen());
  }
}

class BodyAccountScreen extends StatefulWidget {
  const BodyAccountScreen({Key? key}) : super(key: key);

  @override
  _BodyAccountScreenState createState() => _BodyAccountScreenState();
}

class _BodyAccountScreenState extends State<BodyAccountScreen>
    with SingleTickerProviderStateMixin {
  late UserBloc? ub;

  @override
  void initState() {
    super.initState();
    ub = Provider.of<UserBloc>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          const SizedBox(height: 5),
          Center(
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông Tin Cá Nhân',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFA71C20)),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Container(
                                width: 200,
                                height: 200,
                                child: Image.network(
                                  ub?.hinhAnhUrl ?? "",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const DividerWidget(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 18,
                                child: Icon(
                                  Feather.user_check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ub?.name ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const DividerWidget(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 18,
                                child: Icon(
                                  Feather.user_plus,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ub?.accessRole ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const DividerWidget(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigoAccent[100],
                                radius: 18,
                                child: const Icon(
                                  Feather.mail,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ub?.email ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE96327),
            Color(0xFFBC2925),
          ],
        ),
      ),
      child: Center(
        child: customTitle(
          'KIỂM TRA - THÔNG TIN CÁ NHÂN',
        ),
      ),
    );
  }
}
