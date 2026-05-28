part of '../main.dart';

Future<void> logoutDirect(BuildContext context) async {
  if (!context.mounted) return;
  Navigator.of(
    context,
  ).pushAndRemoveUntil(page(const RoleScreen()), (_) => false);
  await Future<void>.delayed(const Duration(milliseconds: 350));
  try {
    await auth.signOut();
  } catch (_) {
    // Logout should always return the user to role selection in demo mode.
  }
  AppSession.clear();
}

Widget shell(
  String title,
  int i,
  ValueChanged<int> set,
  List<Widget> pages,
  List<NavigationDestination> nav,
) => Scaffold(
  appBar: AppBar(
    title: Text(title),
    actions: [
      Builder(
        builder: (context) => IconButton(
          onPressed: () => logoutDirect(context),
          icon: const Icon(Icons.logout),
        ),
      ),
    ],
  ),
  body: pages[i],
  bottomNavigationBar: NavigationBar(
    selectedIndex: i,
    onDestinationSelected: set,
    destinations: nav,
  ),
);
