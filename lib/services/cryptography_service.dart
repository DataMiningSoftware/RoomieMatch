import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:RoomieMatch/services/message_key_db_service.dart';
import 'package:intl/intl.dart';
import 'package:pointycastle/export.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:basic_utils/basic_utils.dart';

import 'api_service.dart';

class CryptographyService {
  static final ApiService apiService = ApiService();

  // Initializes RSA key pair and stores private key securely
  static Future<void> initRSA() async {
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = generateRSAKeyPair();

    // Convert RSAPrivateKey to PEM format and store in secure storage
    String privateKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(keyPair.privateKey);
    await secureWrite("private_key", privateKeyPEM);

    // Send public key to backend to encrypt
    String publicKeyPEM = CryptoUtils.encodeRSAPublicKeyToPem(keyPair.publicKey);
    await sendPublicKey(publicKeyPEM);
  }

  // Generates a new RSA key pair using PointyCastle library
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair() {
    // Generate secure random seed for key generation
    Random random = Random.secure();
    List<int> seeds = List<int>.generate(32, (_) => random.nextInt(256));

    FortunaRandom secureRandom = FortunaRandom();
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    // Generate RSA key pair with 2048-bit key size
    RSAKeyGenerator keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64), secureRandom),
      );

    final AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();

    // Cast keys to RSA-specific types
    RSAPublicKey publicKey = keyPair.publicKey as RSAPublicKey;
    RSAPrivateKey privateKey = keyPair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(publicKey, privateKey);
  }

  // Test function to verify encryption/decryption flow
  static Future<void> test() async {
    String te = "output should be ok";

    int keyId = 0;
    print("te");
    print(te);
    AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = CryptographyService.generateRSAKeyPair();

    // Store generated private key in DB
    String privateKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(keyPair.privateKey);
    await MessageKeyDBService().insertMessageKey(keyId, privateKeyPEM);

    // Send public key to backend
    String publicKeyPEM = CryptoUtils.encodeRSAPublicKeyToPem(keyPair.publicKey);
    await CryptographyService.sendPublicMessageKey(publicKeyPEM, keyId);

    // Fetch recipient's public key from API
    Map<String, dynamic> apiResponse = await apiService.get('messaging/get-messaging-public-key/?user_id=2c5d106e-7401-4468-b264-bc6db2559391');

    // Encrypt message with retrieved public key
    String cipher = await CryptographyService.encryptMessage(apiResponse['publicKey'], te);
    print("cipher");
    print(cipher);

    // Prepare message map to send to backend
    Map<String, dynamic> messageMap = {"recipientUserId": "", "cipherText": "", "keyId": -1, "timestamp": ""};

    String timestamp = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    messageMap['recipientUserId'] = "2c5d106e-7401-4468-b264-bc6db2559391";
    messageMap['cipherText'] = cipher;
    messageMap['keyId'] = apiResponse['keyId'];
    messageMap['timestamp'] = timestamp;

    // Send encrypted message to backend
    Map<String, dynamic> dum = await apiService.post('messaging/send-messages/', messageMap);

    // Retrieve stored private key from DB
    final List<Map<String, dynamic>> keyResponse = await MessageKeyDBService().getMessagesPrivateKeyById(apiResponse['keyId']);

    // Decrypt the message using the stored private key
    String back = await CryptographyService.decryptMessage(keyResponse[0]['private_key'], cipher);
    print("decipher");
    print(back);
  }

  // Securely writes data to FlutterSecureStorage using a given key
  static Future<void> secureWrite(String storageKey, String value) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: storageKey, value: value);
  }

  // Securely reads data from FlutterSecureStorage using a given key
  static Future<String> secureRead(String storageKey) async {
    final storage = FlutterSecureStorage();
    return (await storage.read(key: storageKey) ?? "");
  }

  // Repeatedly sends public key to backend until successful
  static Future<void> sendPublicKey(String publicKey) async {
    String apiResponseStatus;
    bool isIteration = false;

    do {
      Map<String, dynamic> publicKeyMap = {"value": ""};
      publicKeyMap['value'] = publicKey;

      Map<String, dynamic> apiResponse = await apiService.post('db/update-user-public-key/', publicKeyMap);

      apiResponseStatus = apiResponse['status'];

      if (isIteration) {
        await Future.delayed(Duration(seconds: 30));
      }

      isIteration = true;
    } while (apiResponseStatus == 'ERROR' || apiResponseStatus == 'UNKNOWN');
  }

  // Repeatedly sends public key for messaging until successful
  static Future<void> sendPublicMessageKey(String publicKey, int keyId) async {
    String apiResponseStatus;
    bool isIteration = false;

    do {
      Map<String, dynamic> publicKeyMap = {"publicKey": "", "keyId": -1};
      publicKeyMap['publicKey'] = publicKey;
      publicKeyMap['keyId'] = keyId;

      Map<String, dynamic> apiResponse = await apiService.post('messaging/update-messaging-public-key/', publicKeyMap);

      apiResponseStatus = apiResponse['status'];

      if (isIteration) {
        await Future.delayed(Duration(seconds: 30));
      }

      isIteration = true;
    } while (apiResponseStatus == 'ERROR' || apiResponseStatus == 'UNKNOWN');
  }

  // Decrypts a string that was encrypted with RSA and OAEP padding
  static Future<String> decryptRSA(String cipherText) async {
    // Load private key from secure storage
    RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(await secureRead("private_key"));

    // Decode base64 encoded cipher text into bytes
    Uint8List cipherBytes = base64Decode(cipherText);

    // Initialize RSA engine with OAEP padding
    OAEPEncoding decryptor = OAEPEncoding(RSAEngine())..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    // Decrypt the message
    Uint8List decryptedBytes = decryptor.process(cipherBytes);

    // Convert decrypted bytes to UTF-8 string
    String decryptedString = utf8.decode(decryptedBytes);

    return decryptedString;
  }

  // Encrypts a plain text string using a provided RSA public key
  static Future<String> encryptMessage(String publicKeyPEM, String plainText) async {
    // Parse public key from PEM format
    RSAPublicKey publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPEM);

    // Encode plain text to bytes
    Uint8List plainBytes = utf8.encode(plainText);

    // Initialize RSA engine with OAEP padding
    OAEPEncoding encryptor = OAEPEncoding(RSAEngine())..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    // Encrypt the message
    Uint8List encryptedBytes = encryptor.process(plainBytes);

    // Convert encrypted bytes to base64 string
    String encryptedString = base64Encode(encryptedBytes);

    return encryptedString;
  }

  // Decrypts a cipher text string using a provided RSA private key
  static Future<String> decryptMessage(String privateKeyPEM, String cipherText) async {
    // Parse private key from PEM format
    RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPEM);

    // Decode base64 encoded cipher text into bytes
    Uint8List cipherBytes = base64Decode(cipherText);

    // Initialize RSA engine with OAEP padding
    OAEPEncoding decryptor = OAEPEncoding(RSAEngine())..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    // Decrypt the message
    Uint8List decryptedBytes = decryptor.process(cipherBytes);

    // Convert decrypted bytes to UTF-8 string
    String decryptedString = utf8.decode(decryptedBytes);

    return decryptedString;
  }
}