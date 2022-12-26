import 'package:jetter/jetter.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [
        FilePicker((x) => 'myfile'.store(x.first)),
        StreamBuilder<String>(
            builder: (_, name) => Txt('name: $name'),
            create: (context) => onNameChange,
            initialValue: firejetName),
        TextField(onSubmit: (name) => firejetName = name ?? "missing"),
        Button(
          text: "add",
          onTap: () => firejet
              .collection('todos')
              .create({'date': DateTime.now().toIso8601String()}),
        ),
        StreamBuilder<Map>(
            builder: (builder, c) => Column(
                children: c.entries
                    .map<Widget>((e) => Txt(e.value.toString()))
                    .toList()),
            create: (_) => firejet
                .collection('todos')
                .snapshots
                .map((event) => (event.data)),
            initialValue: {})
      ]);
}
