// import 'package:flutter/material.dart';
// import 'package:nowa_runtime/nowa_runtime.dart';
// import 'package:geominder/globals/app_state.dart';
// import 'package:provider/provider.dart';
// import 'package:geominder/models/reminder_model.dart';

// @NowaGenerated()
// class ReminderListScreen extends StatelessWidget {
//   @NowaGenerated({'loader': 'auto-constructor'})
//   const ReminderListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.location_on, color: Theme.of(context).primaryColor),
//             const SizedBox(width: 8),
//             const Text('GeoMinder'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () async {
//               final appState = AppState.of(context, listen: false);
//               await appState.refreshReminders();
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Reminders refreshed')),
//                 );
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               Navigator.of(context).pushNamed('SettingsScreen');
//             },
//           ),
//         ],
//       ),
//       body: Consumer<AppState>(
//         builder: (context, appState, child) {
//           if (appState.isLoading) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading reminders...'),
//                 ],
//               ),
//             );
//           }

//           if (appState.errorMessage != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 64, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Something went wrong',
//                     style: Theme.of(context)
//                         .textTheme
//                         .headlineSmall
//                         ?.copyWith(color: Colors.red),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32),
//                     child: Text(
//                       appState.errorMessage!,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       appState.clearError();
//                       await appState.refreshReminders();
//                     },
//                     child: const Text('Try Again'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (appState.reminders.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No reminders yet',
//                     style: Theme.of(context)
//                         .textTheme
//                         .headlineSmall
//                         ?.copyWith(color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32),
//                     child: Text(
//                       'Tap the + button to add your first location reminder',
//                       style: TextStyle(color: Colors.grey[500]),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () => appState.refreshReminders(),
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: appState.reminders.length,
//               itemBuilder: (context, index) {
//                 final reminder = appState.reminders[index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.all(16),
//                     leading: Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: reminder.isActive
//                             ? Theme.of(context).primaryColor.withOpacity(0.1)
//                             : Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       child: Icon(
//                         Icons.location_on,
//                         color: reminder.isActive
//                             ? Theme.of(context).primaryColor
//                             : Colors.grey,
//                       ),
//                     ),
//                     title: Text(
//                       reminder.title,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: reminder.isActive ? null : Colors.grey,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text(
//                           reminder.locationName,
//                           style: TextStyle(
//                             color: reminder.isActive
//                                 ? Colors.grey[600]
//                                 : Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.radio_button_checked,
//                               size: 12,
//                               color: reminder.isActive
//                                   ? Colors.green
//                                   : Colors.grey,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               reminder.isActive ? 'Active' : 'Inactive',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: reminder.isActive
//                                     ? Colors.green
//                                     : Colors.grey,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Icon(
//                               Icons.adjust,
//                               size: 12,
//                               color: Colors.grey[500],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${reminder.radius.round()}m',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     trailing: PopupMenuButton(
//                       itemBuilder: (context) => [
//                         PopupMenuItem(
//                           value: 'toggle',
//                           child: Row(
//                             children: [
//                               Icon(
//                                 reminder.isActive
//                                     ? Icons.pause
//                                     : Icons.play_arrow,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 reminder.isActive ? 'Deactivate' : 'Activate',
//                               ),
//                             ],
//                           ),
//                         ),
//                         const PopupMenuItem(
//                           value: 'delete',
//                           child: Row(
//                             children: [
//                               Icon(Icons.delete,
//                                   size: 20, color: Colors.red),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Delete',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       onSelected: (value) async {
//                         switch (value) {
//                           case 'toggle':
//                             final success = await appState
//                                 .toggleReminderActive(reminder.id!);
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     success
//                                         ? 'Reminder ${reminder.isActive ? 'deactivated' : 'activated'}'
//                                         : 'Failed to update reminder',
//                                   ),
//                                   backgroundColor: success
//                                       ? Colors.green
//                                       : Colors.red,
//                                 ),
//                               );
//                             }
//                             break;

//                           case 'delete':
//                             _showDeleteDialog(context, appState, reminder);
//                             break;
//                         }
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.of(context).pushNamed('AddReminderScreen');
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _showDeleteDialog(
//     BuildContext context,
//     AppState appState,
//     ReminderModel reminder,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Reminder'),
//         content: Text('Are you sure you want to delete "${reminder.title}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
//               final success = await appState.removeReminder(reminder.id!);
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       success
//                           ? 'Reminder deleted successfully'
//                           : 'Failed to delete reminder',
//                     ),
//                     backgroundColor: success ? Colors.green : Colors.red,
//                   ),
//                 );
//               }
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:geominder/globals/app_state.dart';
import 'package:provider/provider.dart';
import 'package:geominder/models/reminder_model.dart';

@NowaGenerated()
class ReminderListScreen extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('GeoMinder'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final appState = AppState.of(context, listen: false);
              await appState.refreshReminders();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminders refreshed')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('SettingsScreen');
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading reminders...'),
                ],
              ),
            );
          }

          if (appState.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      appState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      appState.clearError();
                      await appState.refreshReminders();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (appState.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Tap the + button to add your first location reminder',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => appState.refreshReminders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appState.reminders.length,
              itemBuilder: (context, index) {
                final reminder = appState.reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: reminder.isActive
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: reminder.isActive
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      reminder.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: reminder.isActive ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          reminder.locationName,
                          style: TextStyle(
                            color: reminder.isActive
                                ? Colors.grey[600]
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              size: 12,
                              color: reminder.isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: reminder.isActive
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.adjust,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${reminder.radius.round()}m',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                reminder.isActive
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                reminder.isActive ? 'Deactivate' : 'Activate',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        final rootContext = context; // save safe context
                        switch (value) {
                          case 'toggle':
                            final success = await appState
                                .toggleReminderActive(reminder!);
                            if (!rootContext.mounted) return;
                            ScaffoldMessenger.of(rootContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Reminder ${reminder.isActive ? 'deactivated' : 'activated'}'
                                      : 'Failed to update reminder',
                                ),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                            break;

                          case 'delete':
                            _showDeleteDialog(rootContext, appState, reminder);
                            break;
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('AddReminderScreen');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext rootContext,
    AppState appState,
    ReminderModel reminder,
  ) {
    showDialog(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // close dialog first
              final success = await appState.removeReminder(reminder.id!);
              if (!rootContext.mounted) return;
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Reminder deleted successfully'
                        : 'Failed to delete reminder',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
