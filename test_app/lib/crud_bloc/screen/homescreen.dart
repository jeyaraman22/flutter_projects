
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_event.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_main.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_state.dart';
import 'bloc_add_editscreen.dart';
import '../crud_bloc_model/bloc_modelclass.dart';

class BlocHomeScreen extends StatefulWidget {
  const BlocHomeScreen({Key? key}) : super(key: key);

  @override
  _BlocHomeScreenState createState() => _BlocHomeScreenState();
}

class _BlocHomeScreenState extends State<BlocHomeScreen> {
  List<Chemicalproduct> productList = [];
  final crudBloc = ProductBloc();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductEvent());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bloc_Form"),
      actions: [
        IconButton(onPressed:(){
         context.read<ProductBloc>().add(NewScreenEvent());
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => BlocAddEditScreen(action: "add")));
        }, icon: const Icon(Icons.add),),
      ],),
      body: BlocListener<ProductBloc,CrudState>(
        listener: (context,state){
          if(state is NewScreenState){
            print("NEW SCREE EVENT");
             Navigator.push(context,
                MaterialPageRoute(builder: (context) => BlocAddEditScreen(action: "add")));
          }
          if(state is GetProductState){
            if(state.process == "add"){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data has been Added Successfully")));
            }
            if(state.process == "edit"){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data has been Updated Successfully")));
            }
            if(state.process == "delete"){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data has been Deleted Successfully")));
            }
          }
        },
        child: BlocBuilder<ProductBloc,CrudState>(
            builder: (context,state){
          if(state is InitialState){
            return const Center(child: CircularProgressIndicator(),);
          }
        if(state is GetProductState){
          print("Get Product State..");
          print(state.productList.length);
          return displayProducts(context, state.productList,state.process);
        }else{
            return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  color: Colors.pink,
                  strokeWidth: 2.0,
                ));
        }
        }),
      ),
    );
  }
  Widget displayProducts(BuildContext context, List<Chemicalproduct> productList,String snackBarAction){
    return Column(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ListView.builder(
            itemCount: productList.length,
              itemBuilder: (context, index){
              final item = productList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name:${item.name}", style: Theme
                          .of(context)
                          .textTheme
                          .headline4,),
                      const SizedBox(height: 5,),
                      Text("Formula:${item.formula}", style: Theme
                          .of(context)
                          .textTheme
                          .headline5,),
                      const SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () async {
                             Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    BlocAddEditScreen(
                                      action: "Edit", editProduct: item,)));
                          }, child: const Text("Edit",
                            style: TextStyle(
                                color: Colors.lightGreen, fontSize: 22),)),
                          const SizedBox(width: 10,),
                          TextButton(onPressed: () {
                            context.read<ProductBloc>().add(DeleteEvent(item.id!));
                          }, child: const Text("Delete",
                            style: TextStyle(color: Colors.pink, fontSize: 22),))
                        ],)
                    ],
                  ),
                );

          }),
        ),
      ],
    );
  }
}
