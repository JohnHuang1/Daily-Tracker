import 'package:daily_tracker/models/dialog_models.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:flutter/material.dart';
import '../locator.dart';

class DialogManager extends StatefulWidget {
  final Widget child;

  DialogManager({Key key, this.child}) : super(key: key);

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService = locator<DialogService>();

  @override
  void initState() {
    super.initState();
    _dialogService.registerDialogListener(_showDialog);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _showDialog(DialogRequest request) {
    TextEditingController inputController = TextEditingController();
    var isConfirmationDialog = request.cancelTitle != null;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(request.title),
              content: request.input1 == null || !request.input1
                  ? Text(request.description)
                  : TextFormField(
                controller: inputController,
                maxLength: 100,
                decoration: InputDecoration.collapsed(
                  hintText: request.description,
                ),
              ),
              actions: <Widget>[
                if (isConfirmationDialog)
                  TextButton(
                    child: Text(request.cancelTitle),
                    onPressed: () {
                      _dialogService
                          .dialogComplete(DialogResponse(confirmed: false));
                    },
                  ),
                TextButton(
                  child: Text(request.buttonTitle),
                  onPressed: () {
                    if (request.input1 == null || !request.input1) {
                      _dialogService
                          .dialogComplete(DialogResponse(confirmed: true));
                    } else if (inputController.text.length > 0) {
                      _dialogService.dialogComplete(DialogResponse(
                          confirmed: true,
                          fieldOne: inputController.value.text));
                    } else {
                      _showToast(context);
                    }
                  },
                ),
              ],
            ));
  }

  void _showToast(BuildContext context){
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text('Name cannot be blank',
      style: TextStyle(
        color: Colors.red,
      ))
    ));
  }
}
