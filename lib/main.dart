import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tech News & To-Do',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tech News & To-Do'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'To-Do List'),
              Tab(text: 'Tech News'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ToDoListScreen(),
            TechNewsScreen(),
          ],
        ),
      ),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  Map<String, List<String>> tasksByCategory = {};

  void addTask(String category, String task) {
    if (!tasksByCategory.containsKey(category)) {
      tasksByCategory[category] = [];
    }
    setState(() {
      tasksByCategory[category]!.add(task); // Use '!' to assert that tasksByCategory[category] is not null
    });
  }

  void deleteTask(String category, int index) {
    if (tasksByCategory.containsKey(category)) {
      setState(() {
        tasksByCategory[category]!.removeAt(index); // Use '!' to assert that tasksByCategory[category] is not null
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Enter a task'),
          onSubmitted: (task) => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Enter category for the task'),
                content: TextField(
                  onChanged: (category) {
                    addTask(category, task);
                    Navigator.pop(context); // Close the dialog
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasksByCategory.length,
            itemBuilder: (context, categoryIndex) {
              var category = tasksByCategory.keys.elementAt(categoryIndex);
              var tasks = tasksByCategory[category] ?? []; // Use null aware operator

              return ExpansionTile(
                title: Text(category),
                children: tasks.map((task) {
                  var taskIndex = tasks.indexOf(task);
                  return ListTile(
                    title: Text(task),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteTask(category, taskIndex),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}


class TechNewsScreen extends StatefulWidget {
  const TechNewsScreen({super.key});

  @override
  _TechNewsScreenState createState() => _TechNewsScreenState();
}

class _TechNewsScreenState extends State<TechNewsScreen> {
  List<dynamic> news = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'));
    if (response.statusCode == 200) {
      final List<dynamic> storyIds = json.decode(response.body);
      final List<Future<dynamic>> futures = storyIds.take(10).map((id) {
        return http.get(Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'));
      }).toList();

      final results = await Future.wait(futures);

      setState(() {
        news = results.map((response) => json.decode(response.body)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(news[index]['title']),
          subtitle: Text('By: ${news[index]['by']}'),
        );
      },
    );
  }
}
