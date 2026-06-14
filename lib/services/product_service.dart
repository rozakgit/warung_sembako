import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProducts() {

    return firestore
        .collection('products')
        .snapshots();
  }

  Future addProduct({

    required String name,
    required String price,
    required String stock,
    required String image,

  }) async {

    await firestore
        .collection('products')
        .add({

      'name': name,

      'price': price,

      'stock': stock,

      'image': image,

      'isActive': true,

      'createdAt':
      FieldValue.serverTimestamp(),
    });
  }

  Future updateProduct({

    required String docId,
    required String name,
    required String price,
    required String stock,

  }) async {

    await firestore
        .collection('products')
        .doc(docId)
        .update({

      'name': name,

      'price': price,

      'stock': stock,
    });
  }

  Future deleteProduct(
      String docId,
      ) async {

    await firestore
        .collection('products')
        .doc(docId)
        .delete();
  }

  Future toggleStatus({

    required String docId,

    required bool currentStatus,

  }) async {

    await firestore
        .collection('products')
        .doc(docId)
        .update({

      'isActive': !currentStatus,
    });
  }
}