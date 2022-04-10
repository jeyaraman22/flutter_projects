import 'package:flutter/material.dart';
import 'package:test_app/customTreeview/utils/constants.dart';
import '../widgets/custom_tree_view_widgets/customtreeview.dart';
import '../widgets/custom_tree_view_widgets/customtreeviewcontroller.dart';
import '../widgets/custom_tree_view_widgets/customnode.dart';
import '../widgets/custom_tree_view_widgets/customtreeviewtheme.dart';

class TreeViewHomePage extends StatefulWidget {
  const TreeViewHomePage({Key? key}) : super(key: key);

  @override
  _TreeViewHomePageState createState() => _TreeViewHomePageState();
}

class _TreeViewHomePageState extends State<TreeViewHomePage> {

  TreeViewController? treeViewController;
  String? selectedNode;
  List<Node>? nodes;

  @override
  void initState() {
    super.initState();
    nodes = [
      Node(
        label: NodeStrings.document,
        key: NodeStrings.docKey,
        expanded: Constant.docsOpenFalse,
        icon: Icons.folder,
        children: [
           Node(
              label: NodeStrings.personal,
              key: NodeStrings.personalKey,
              icon: Icons.input,
              children: [
                Node(
                    label: NodeStrings.resume,
                    key: NodeStrings.resumeKey,
                    icon: (Icons.insert_drive_file)),
                Node(
                    label: NodeStrings.coverLetter,
                    key: NodeStrings.coverLetterKey,
                    icon: (Icons.insert_drive_file)),
              ]),
          Node(
            label: NodeStrings.inspection,
            key: NodeStrings.inspectionKey,
          icon: (Icons.insert_drive_file),
          ),
          Node(
              label: NodeStrings.invoice,
              key: NodeStrings.invoiceKey,
              icon: Icons.insert_drive_file),
        ],
      ),
       Node(
          label: NodeStrings.meetingReport1,
          key: NodeStrings.meeting1Key,
          icon: (Icons.insert_drive_file)),
       Node(
          label: NodeStrings.meetingReport2,
          key: NodeStrings.meeting2Key,
          icon: (Icons.insert_drive_file)),
       Node(
          label: NodeStrings.demo,
          key: NodeStrings.demoKey,
          icon: (Icons.archive)),
    ];
    treeViewController = TreeViewController(children: nodes!,selectedKey: selectedNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarStrings.header),
      ),
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: TreeView(controller: treeViewController!,
              shrinkWrap: Constant.shrinkWrapTrue,
            theme: const TreeViewTheme(),)
          ),
        ],
      ),
    );
  }
}
