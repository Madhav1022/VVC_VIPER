import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../presenters/camera_presenter.dart';
import '../../utils/constants.dart';
import 'camera_view.dart';

class CameraPage extends StatefulWidget {
  static const String routeName = 'camera';
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> implements CameraView {
  final CameraPresenter _presenter = CameraPresenter();

  @override
  void refreshUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
        backgroundColor: Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _presenter.isFormValid ? () => _presenter.createContact(context) : null,
            icon: const Icon(Icons.arrow_forward),
            color: _presenter.isFormValid ? Colors.white : Colors.grey.shade400,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  EasyLoading.show(status: "Processing...");
                  await _presenter.processImage(ImageSource.camera);
                  EasyLoading.dismiss();
                  refreshUI();
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Camera', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.deepPurple,
                  elevation: 5,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  EasyLoading.show(status: "Processing...");
                  await _presenter.processImage(ImageSource.gallery);
                  EasyLoading.dismiss();
                  refreshUI();
                },
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Gallery', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.indigo,
                  elevation: 5,
                ),
              ),
            ],
          ),
          if (_presenter.isScanOver)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DragTargetItem(property: ContactProperties.name, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.mobile, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.email, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.company, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.designation, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.address, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.website, onDrop: (property, value) {
                      _presenter.updatePropertyValue(property, value);
                      refreshUI();
                    }),
                  ],
                ),
              ),
            ),
          if (_presenter.isScanOver)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(hint),
            ),
          Wrap(
            spacing: 8,
            children: _presenter.lines.map((line) => LineItem(line: line)).toList(),
          )
        ],
      ),
    );
  }
}

class DragTargetItem extends StatefulWidget {
  final String property;
  final Function(String, String) onDrop;

  const DragTargetItem({super.key, required this.property, required this.onDrop});

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  List<String> dragItems = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            widget.property,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: candidateData.isNotEmpty
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dragItems.isEmpty ? 'Drop here' : dragItems.join(' '),
                    ),
                  ),
                  if (dragItems.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          dragItems.clear();
                        });
                        widget.onDrop(widget.property, '');
                      },
                      child: const Icon(Icons.clear, size: 15, color: Colors.red),
                    ),
                ],
              ),
            ),
            onAccept: (value) {
              setState(() {
                if (!dragItems.contains(value)) {
                  dragItems.add(value);
                }
              });
              widget.onDrop(widget.property, dragItems.join(' '));
            },
          ),
        ),
      ],
    );
  }
}

class LineItem extends StatelessWidget {
  final String line;
  const LineItem({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.black38,
        ),
        child: Text(line, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
      ),
      child: Chip(
        label: Text(line),
      ),
    );
  }
}
