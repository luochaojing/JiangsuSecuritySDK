/*
 * OpensslWapper.h
 *
 *  Created on: 2012-11-3
 *      Author: apple
 */

#ifndef OPENSSLWAPPER_H_
#define OPENSSLWAPPER_H_

#include <iostream>


/*
#include "openssl/sha.h"
#include "openssl/bn.h"
#include "openssl/ec.h"
#include "openssl/rand.h"
#include "openssl/err.h"
#include "openssl/ecdsa.h"
*/
#include <openssl/sha.h>
#include <openssl/bn.h>
#include <openssl/ec.h>
#include <openssl/rand.h>
#include <openssl/err.h>
#include <openssl/ecdsa.h>

//#include "Global.h"

class OpensslWapper {
public:
	OpensslWapper();
    static void generateRSAKey(int strengLen, std::string& publicKey,
                               std::string& privateKey);
    static int sign(std::string& privateKey, std::string& data, std::string& signData,
                    const char * hashAlg);
	static bool verify(std::string& publicKey, std::string&data, std::string& signData);
    
    //~~~自己加的~~~可以传入签名算法sha1
    static bool verifySha1(std::string publicKey, std::string& data, std::string& signData);
    //~~~上面自己加的~~~~
    
    
    static bool encrypt(const std::string& keyInfor, const std::string& data,
                        std::string& encrytData);
    static bool decrypt(const std::string& keyInfor, const std::string& data,
                        std::string& decrytData);
	static std::string desede(const std::string& secKey, bool encryptFlag,
			const std::string& source);
	static std::string aes(const std::string& secKey, bool encryptFlag,
			const std::string& source);
    
    /**定义对称加密分段加密方法 分别为上下文初始化 分段持续加密、结束加密 通过静态的结构体上下文实现 */
    static EVP_CIPHER_CTX updateCtx;
    static void symmetricEncodeInit(const std::string& secKey,bool encryptFlag);
    static std::string symmetricEncodeUpdate(const std::string& source,bool encryptFlag);
    static std::string symmetricEncodeFinish(bool encryptFlag);
    static std::string checkCertExpire(const std::string& certData);
    
	static std::string MD5(const std::string& content);
	static std::string md5(const std::string& content);
	static std::string sha1(const std::string& content);
	static std::string hex(std::string& content);
	static std::string randContent(int length);
	static std::string digest(const std::string& content,const char * algo);

	static std::string encode_RSA_publicKey(const std::string& publicKey,
			const std::string& data);
    //static std::string encode_RSA_publicKey1(const std::string& publicKey,
                                                     //unsigned char* data);
	static std::string decode_RSA_privateKey(const std::string& privateKey,
			const std::string& data);

	static int HmacEncode(const char * algo, const char * key,
			unsigned int key_length, const char * input,
			unsigned int input_length, unsigned char * &output,
			unsigned int &output_length);
	virtual ~OpensslWapper();
    
    
    static X509* getX509ByString(std::string &string);
    
};

#endif /* OPENSSLWAPPER_H_ */
