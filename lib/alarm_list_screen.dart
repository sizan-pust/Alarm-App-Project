// //alarm_list_screen.dart
// import 'package:esp/add_alarm.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'alarm_model.dart';
// import 'alarm_provider.dart';

// class AlarmListScreen extends StatelessWidget {
//   const AlarmListScreen({super.key});

//   String _getMonthYear(DateTime date) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return '${months[date.month - 1]} ${date.year}';
//   }

//   List<Widget> _buildDateRow(DateTime now) {
//     final today = DateTime.now().day;
//     final currentMonth = DateTime.now().month;
//     final currentYear = DateTime.now().year;

//     // Get the first day of the current month
//     final firstDay = DateTime(currentYear, currentMonth, 1);
//     final lastDay = DateTime(currentYear, currentMonth + 1, 0).day;

//     // Calculate starting position (which day of week does month start on)
//     final startingDayOfWeek = firstDay.weekday % 7; // 0 = Sunday, 6 = Saturday

//     // Get previous month's last day for padding
//     final prevMonthLastDay = DateTime(currentYear, currentMonth, 0).day;
//     final prevDaysToShow = startingDayOfWeek;

//     List<Widget> widgets = [];

//     // Add days from previous month
//     for (int i = 0; i < prevDaysToShow; i++) {
//       widgets.add(
//         _buildDateBox(
//           (prevMonthLastDay - prevDaysToShow + i + 1).toString(),
//           false,
//           false,
//         ),
//       );
//     }

//     // Add days of current month
//     for (int day = 1; day <= lastDay; day++) {
//       final isToday = day == today;
//       widgets.add(_buildDateBox(day.toString(), isToday, true));
//     }

//     // Add days from next month if needed
//     final remainingDays = 7 - (widgets.length % 7);
//     if (remainingDays < 7) {
//       for (int day = 1; day <= remainingDays; day++) {
//         widgets.add(_buildDateBox(day.toString(), false, false));
//       }
//     }

//     // Take only the first 7 for a single row
//     return widgets.take(7).toList();
//   }

//   Widget _buildDateBox(String date, bool isToday, bool isCurrentMonth) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 2),
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: isToday ? const Color(0xFFF6C84C) : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Center(
//             child: Text(
//               date,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
//                 color: isCurrentMonth
//                     ? (isToday ? Colors.black87 : Colors.grey)
//                     : Colors.grey[300],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7FB),
//       body: Consumer<AlarmProvider>(
//         builder: (context, provider, child) {
//           return SafeArea(
//             child: Column(
//               children: [
//                 // Top greeting header
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 18,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           Text(
//                             'Good Morning ☀️',
//                             style: TextStyle(color: Colors.grey, fontSize: 14),
//                           ),
//                           SizedBox(height: 6),
//                           Text(
//                             'Soham Ningurkar',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'Let\'s build your habbits',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundImage: null,
//                         backgroundColor: Colors.grey[300],
//                         child: const Icon(Icons.person, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Calendar/Date selector
//                 SizedBox(
//                   height: 100,
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // Month and Year
//                         Text(
//                           _getMonthYear(DateTime.now()),
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                             color: Colors.orange,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         // Days of week and dates
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: _buildDateRow(DateTime.now()),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // Tabs: Alarm / Goals
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF6C84C),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               'Alarm',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               'Goals',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Alarms grid or empty state
//                 Expanded(
//                   child: provider.alarms.isEmpty
//                       ? Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(25),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Color.fromRGBO(0, 0, 0, 0.1),
//                                 blurRadius: 8,
//                                 offset: Offset(0, 0),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 height: 200,
//                                 child: Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     Image.asset(
//                                       'assets/images/icon1.png',
//                                       width: 200,
//                                       height: 180,
//                                       fit: BoxFit.contain,
//                                       errorBuilder: (_, __, ___) => Icon(
//                                         Icons.person_3,
//                                         size: 150,
//                                         color: Colors.grey[300],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               const Text(
//                                 'No Alarm found',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w400,
//                                   color: Colors.black,
//                                   fontFamily: 'SF Pro Text',
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 'Add alarm to set goals',
//                                 style: TextStyle(
//                                   color: Color(0xFFA9A9A9),
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w300,
//                                   fontFamily: 'SF Pro Text',
//                                 ),
//                               ),
//                               const SizedBox(height: 30),
//                             ],
//                           ),
//                         )
//                       : Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: GridView.builder(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   mainAxisSpacing: 12,
//                                   crossAxisSpacing: 12,
//                                   childAspectRatio: 1.15,
//                                 ),
//                             itemCount: provider.alarms.length,
//                             itemBuilder: (context, index) {
//                               final alarm = provider.alarms[index];
//                               return FigmaAlarmCard(
//                                 alarm: alarm,
//                                 onToggle: () => provider.toggleAlarm(alarm.id),
//                                 onEdit: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           AddAlarmScreen(alarm: alarm),
//                                     ),
//                                   );
//                                 },
//                                 onDelete: () => _showDeleteDialog(
//                                   context,
//                                   alarm.id,
//                                   provider,
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       // Bottom navigation with centered FAB
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
//           );
//         },
//         backgroundColor: const Color(0xFFF6C84C),
//         child: const Icon(Icons.add, color: Colors.black87),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.calendar_today),
//               ),
//               const SizedBox(width: 48), // space for FAB
//               IconButton(onPressed: () {}, icon: const Icon(Icons.bar_chart)),
//               IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(
//     BuildContext context,
//     String alarmId,
//     AlarmProvider provider,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Alarm'),
//         content: const Text('Are you sure you want to delete this alarm?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               provider.deleteAlarm(alarmId);
//               Navigator.pop(context);
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AlarmCard extends StatelessWidget {
//   final Alarm alarm;
//   final VoidCallback onToggle;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const AlarmCard({
//     super.key,
//     required this.alarm,
//     required this.onToggle,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Switch(
//                       value: alarm.isActive,
//                       onChanged: (value) => onToggle(),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       alarm.formattedTime,
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: alarm.isActive ? Colors.blue : Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       alarm.dayPeriod,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: alarm.isActive ? Colors.blue : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'edit') onEdit();
//                     if (value == 'delete') onDelete();
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, size: 20),
//                           SizedBox(width: 8),
//                           Text('Edit'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete, size: 20, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('Delete', style: TextStyle(color: Colors.red)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               alarm.label,
//               style: TextStyle(
//                 fontSize: 18,
//                 color: alarm.isActive ? Colors.black87 : Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               alarm.repeatText,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: alarm.isActive ? Colors.blue : Colors.grey,
//               ),
//             ),
//             if (!alarm.isActive)
//               const Padding(
//                 padding: EdgeInsets.only(top: 8),
//                 child: Text(
//                   'Alarm is off',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.red,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FigmaAlarmCard extends StatelessWidget {
//   final Alarm alarm;
//   final VoidCallback onToggle;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const FigmaAlarmCard({
//     super.key,
//     required this.alarm,
//     required this.onToggle,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onEdit,
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//           border: Border.all(
//             color: alarm.isActive ? Colors.yellow.shade700 : Colors.transparent,
//             width: alarm.isActive ? 1.5 : 0,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       alarm.formattedTime,
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: alarm.isActive ? Colors.black87 : Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       alarm.dayPeriod,
//                       style: TextStyle(
//                         color: alarm.isActive ? Colors.black54 : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
//                     PopupMenuButton<String>(
//                       onSelected: (v) {
//                         if (v == 'edit') onEdit();
//                         if (v == 'delete') onDelete();
//                       },
//                       itemBuilder: (_) => const [
//                         PopupMenuItem(value: 'edit', child: Text('Edit')),
//                         PopupMenuItem(
//                           value: 'delete',
//                           child: Text(
//                             'Delete',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               alarm.label,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: alarm.isActive ? Colors.black87 : Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               alarm.repeatText,
//               style: TextStyle(
//                 color: alarm.isActive ? Colors.blue : Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            // 🔹 TOP SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Good Morning ☀️",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Soham Ningurkar",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Let’s build your habbits",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // PROFILE IMAGE
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(
                      'assets/profile.jpg',
                    ), // your image
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 DATE SELECTOR
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text("Sun\n30"),
                    Text("Mon\n31"),
                    Text("Tue\n1"),
                    Text(
                      "Wed\n2",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Thu\n3"),
                    Text("Fri\n4"),
                  ],
                ),

                const SizedBox(height: 10),

                // SELECTED DAY CIRCLE
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFFE082)],
                    ),
                  ),
                  child: const Text(
                    "2",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "February 2022",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFA726),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 TAB (Alarm / Goals)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          "Alarm",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Center(child: Text("Goals")),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 EMPTY STATE
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/sleep.png', // your sleeping image
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Alarm found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Add alarm to set goals",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🔹 FLOATING BUTTON
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFE082)],
          ),
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔹 BOTTOM NAV
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, color: Colors.orange),
            Icon(Icons.show_chart),
            SizedBox(width: 40), // space for FAB
            Icon(Icons.star_border),
            Icon(Icons.settings),
          ],
        ),
      ),
    );
  }
}
