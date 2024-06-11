import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


typedef void IntCallback(int value);


class NumberEditor extends StatefulWidget {
    final IntCallback callback;
    final int _init;
    final int _min;
    final int _max;
    const NumberEditor(this._init, this._min, this._max, this.callback);

    @override
    createState() => NumberEditorState();
}

class NumberEditorState extends State<NumberEditor> {
    @override
    void initState() {
        super.initState();
        _current = widget._init;
        _text.text = _current.toString();
    }

    final _text = TextEditingController();
    // int _min = 0;
    // int _max = 5000;
    int _current = 20;

    // String _validator(String value) {
    //     if(value == null) { return _current.toString(); }
    //     final int n = num.tryParse(value);
    //     if(n == null) { return _current.toString(); }
    //     if(n < _min || n > _max) { return _current.toString(); }
    //     return n.toString();
    // }

    String? _validator(String? value) {
        if(value == null) { return "Incorrect Value"; }
        String val = value;
        final int? n = int.tryParse(val);
        if(n == null) { return "Incorrect Value"; }
        if(n < widget._min || n > widget._max) { return "Incorrect Value"; }
        return null;
    }

    _onChange(int value) {
        if (value != null && value > widget._min && value < widget._max) 
        setState(() { 
            _current = value;
            _text.text = value.toString();
            widget.callback(value);
        });
        
        // setState(() { _current = value.round(); _text.text = _current.toString(); });
    }

    @override
    Widget build(BuildContext context) {
        return Expanded(child: Row(
            children: <Widget>[
                Expanded( child: Slider(
                    value: _current *  1.0,
                    min: widget._min *  1.0,
                    max: widget._max *  1.0,
                    divisions: (widget._max - widget._min).ceil(),
                    label: _current.round().toString(),
                    onChanged: (double value) { _onChange(value.round()); },
                )),
                Container(
                    width: 100,
                    child:  TextFormField(
                        keyboardType: TextInputType.number,
                        validator: _validator,
                        onChanged: (String value) {
                            final int? n = int.tryParse(value);
                            if (n!=null) _onChange(n);
                        },
                        controller: _text,
                    )
                ),
            ]
        ));
    }
}