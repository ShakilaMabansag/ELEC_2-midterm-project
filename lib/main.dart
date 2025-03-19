import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

void main() {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade900,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class Task {
  String title;
  DateTime? dueDate;
  bool isCompleted;

  Task({required this.title, this.dueDate, this.isCompleted = false});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  TextEditingController taskController = TextEditingController();
  DateTime? selectedDate;

  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(title: taskController.text, dueDate: selectedDate));
      });
      taskController.clear();
      selectedDate = null;
    }
  }

  void editTask(int index, String newTitle, DateTime? newDate) {
    setState(() {
      tasks[index].title = newTitle;
      tasks[index].dueDate = newDate;
    });
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade900,
                labelText: 'Enter Task',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(selectedDate == null ? 'Set Due Date' : 'Due: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: addTask,
              child: Text('Add Task'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        tasks[index].title,
                        style: TextStyle(
                          decoration: tasks[index].isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: tasks[index].dueDate != null
                          ? Text('Due: ${DateFormat('yyyy-MM-dd').format(tasks[index].dueDate!)}', style: TextStyle(color: Colors.white70))
                          : null,
                      trailing: Checkbox(
                        value: tasks[index].isCompleted,
                        onChanged: (value) => toggleTaskCompletion(index),
                        activeColor: Colors.green,
                      ),
                      onTap: () => _showEditDialog(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green.shade900,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.color_lens, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BackgroundColorScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.music_note, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AudioPlayerScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(int index) {
    TextEditingController editController = TextEditingController(text: tasks[index].title);
    DateTime? selectedDate = tasks[index].dueDate;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text('Set Due Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              editTask(index, editController.text, selectedDate);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerScreen extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Player')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.green.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/badguy.jpg',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Bad Bitch Rap',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.white),
                          iconSize: 40,
                          onPressed: () async {
                            await _audioPlayer.play(AssetSource('bad-bitch-rap.mp3'));
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.pause, color: Colors.white),
                          iconSize: 40,
                          onPressed: () async {
                            await _audioPlayer.pause();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.stop, color: Colors.white),
                          iconSize: 40,
                          onPressed: () async {
                            await _audioPlayer.stop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class BackgroundColorScreen extends StatefulWidget {
  @override
  _BackgroundColorScreenState createState() => _BackgroundColorScreenState();
}

class _BackgroundColorScreenState extends State<BackgroundColorScreen> {
  Color _backgroundColor = const Color.fromARGB(255, 4, 23, 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Color Changer')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          setState(() {
            if (details.primaryVelocity! > 0) {
              // Swipe Right -> Sage Green
              _backgroundColor = const Color(0xFF9CAF88);
            } else if (details.primaryVelocity! < 0) {
              // Swipe Left -> Dark Grey
              _backgroundColor = const Color(0xFF2E2E2E);
            }
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          color: _backgroundColor,
          child: Center(
            child: Text(
              'Swipe to Change Color',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Disable debug banner
//       home: SwipeScreen(),
//     );
//   }
// }

// class SwipeScreen extends StatefulWidget {
//   @override
//   _SwipeScreenState createState() => _SwipeScreenState();
// }

// class _SwipeScreenState extends State<SwipeScreen> {
//   String _currentScreen = 'Login'; // Default screen is Login

//   // Function to handle the swipe gestures
//   void _onSwipe(DragUpdateDetails details) {
//     if (details.primaryDelta! < 0) {
//       // Swipe left (negative delta value means swipe left)
//       setState(() {
//         _currentScreen = 'Login';
//       });
//     } else if (details.primaryDelta! > 0) {
//       // Swipe right (positive delta value means swipe right)
//       setState(() {
//         _currentScreen = 'Registration';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ELEC_2'),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         elevation: 0,
//       ),
//       body: GestureDetector(
//         onHorizontalDragUpdate: _onSwipe, // Detect horizontal swipe
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.teal.shade100, Colors.teal.shade400],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Center(
//                   child : Text(
//                     "ELEC_2",
//                       style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   ),
//                   SizedBox(height: 30),
//                   Container(
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: _currentScreen == 'Login'
//                         ? LoginScreen()
//                         : RegistrationScreen(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class LoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           "Login",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
//         ),
//         SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center, // Centers the fields horizontally
//           children: [
//             // Username field
//             Container(
//               width: 140, // Limit the width for the username field
//               child: TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   hintText: 'Enter your username',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.teal.shade50,
//                 ),
//               ),
//             ),
//             SizedBox(width: 10), // Space between the username and password fields
//             // Password field
//             Container(
//               width: 140, // Limit the width for the password field
//               child: TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.teal.shade50,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 30),
//         ElevatedButton(
//           onPressed: () {},
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.teal,
//             padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: Text(
//             "Login",
//             style: TextStyle(fontSize: 18, color: Colors.white),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class RegistrationScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//    return Column(
//       children: [
//         Text(
//           "Register",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
//         ),
//         SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center, // Centers the fields horizontally
//           children: [
//             // Username field
//             Container(
//               width: 140, // Limit the width for the username field
//               child: TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   hintText: 'Enter your username',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.teal.shade50,
//                 ),
//               ),
//             ),
//             SizedBox(width: 10), // Space between the username and password fields
//             // Password field
//             Container(
//               width: 140, // Limit the width for the password field
//               child: TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.teal.shade50,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center, // Centers the fields horizontally
//           children: [
//             // Confirm Password field
//             Container(
//               width: 140, // Limit the width for the confirm password field
//               child: TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   hintText: 'Confirm your password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.teal.shade50,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 30),
//         ElevatedButton(
//           onPressed: () {},
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.teal,
//             padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: Text(
//             "Register",
//             style: TextStyle(fontSize: 18, color: Colors.white),
//           ),
//         ),
//       ],
//     );
//   }
// }
