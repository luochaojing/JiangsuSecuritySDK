/*
 * OpensslWapper.cpp
 *
 *  Created on: 2012-11-3
 *      Author: lixf
 */
#include <iostream>
#include <string>
#include <limits.h>
/*
#include "openssl/evp.h"
#include "openssl/ec.h"
#include "openssl/bn.h"
#include "openssl/bn.h"
#include "openssl/rand.h"
#include "openssl/ecdsa.h"
#include "openssl/md5.h"
*/
#include <openssl/evp.h>
#include <openssl/evp.h>
#include <openssl/ec.h>
#include <openssl/bn.h>
#include <openssl/rand.h>
#include <openssl/ecdsa.h>
#include <openssl/md5.h>
/*
#include "openssl/ec.h"
#include "openssl/bn.h"
#include "openssl/rand.h"
#include "openssl/err.h"
#include "openssl/ecdsa.h"
#include "openssl/ecdh.h"
*/

#include <openssl/ec.h>
#include <openssl/bn.h>
#include <openssl/rand.h>
#include <openssl/err.h>
#include <openssl/ecdsa.h>
#include <openssl/ecdh.h>

#include <memory.h>
/*
#include "openssl/evp.h"
#include "openssl/sha.h"
#include "openssl/rsa.h"
#include "openssl/hmac.h"
#include "openssl/x509.h"
*/
#include <openssl/evp.h>
#include <openssl/sha.h>
#include <openssl/rsa.h>
#include <openssl/hmac.h>
#include <openssl/x509.h>
#include "Base64.h"
#include "OpensslWapper.h"

#define  NID_X9_62_prime_field 406

#define AES_BLOCK_SIZE 16
//#define RSA_F4 0x10001

OpensslWapper::OpensslWapper() {
}

EVP_CIPHER_CTX OpensslWapper::updateCtx;

void OpensslWapper::generateRSAKey(int strengLen, std::string& publicKey,
		std::string& privateKey) {
	RSA* keyPair = RSA_new();
	BIGNUM* bne = BN_new();
	BN_set_word(bne, RSA_F4);
	RSA_generate_key_ex(keyPair, strengLen, bne, NULL);
	/*
	 RSA* keyPair = RSA_generate_key(strengLen, RSA_F4, NULL, NULL);
	 if(keyPair == NULL) {
	 return;
	 }
	 */
	unsigned char buffer[2048];
	unsigned char* bufferPtr = buffer;
	int len = 0;
	//len = i2d_RSA_PUBKEY(keyPair, &bufferPtr);// using a SubjectPublicKeyInfo (certificate public key) structure.
	len = i2d_RSAPublicKey(keyPair, &bufferPtr); //using p and q
    
	bufferPtr = buffer;
	publicKey.assign(bufferPtr, bufferPtr + len);
	len = i2d_RSAPrivateKey(keyPair, &bufferPtr);
	bufferPtr = buffer;
	privateKey.assign(bufferPtr, bufferPtr + len);

	RSA_free(keyPair);
	keyPair = NULL;
	BN_clear_free(bne);
	bne = NULL;
}

int OpensslWapper::sign(std::string& privateKey, std::string& data, std::string& signData,
		const char * hashAlg) {
	int algType=NID_sha1;
	if(strcasecmp("sha256", hashAlg) == 0) {
		algType = NID_sha256;
	}
	else if(strcasecmp("sha1", hashAlg) == 0) {
		algType = NID_sha1;
	}
	else if(strcasecmp("md5", hashAlg) == 0) {
		algType = NID_md5;
	}
	else {
		//Log::error(TAG, "Algorithm [%s] is not supported by this program!",hashAlg);

		return -1;
	}

	const unsigned char* bufferPtr = (const unsigned char*) privateKey.c_str();
	RSA* key = d2i_RSAPrivateKey(NULL, &bufferPtr, (long) privateKey.length());

    //~~~罗：传入RSA私钥错误时候，RSA *key为空，引起崩溃
    if (key == NULL) {
        return -1;
    }
    //~~罗
    
	unsigned char signBuffer[1024];
	unsigned int signBufferLen = 1024;
	unsigned char* signBufferPtr = signBuffer;
	//compatile with java,must first get hash of the data
	data = digest(data,hashAlg);
	bufferPtr = (const unsigned char*) data.c_str();
	//int result = RSA_sign(NID_sha1WithRSA, bufferPtr, (unsigned int)data.size(), signBuffer, &signBufferLen, key);
	int result = RSA_sign(algType, bufferPtr,
			(unsigned int) data.size(), signBuffer, &signBufferLen, key);
	signBufferPtr = signBuffer;
	signData.assign(signBufferPtr, signBufferPtr + signBufferLen);
	if (result == 1) {
		//success
	} else {
		//failure
		ERR_get_error();
	}
	RSA_free(key);
	key = NULL;
	return result;
}

bool OpensslWapper::verify(std::string& publicKey, std::string&data, std::string& signData) {
	const unsigned char* bufferPtr = (const unsigned char*) publicKey.c_str();
	//RSA*key = d2i_RSA_PUBKEY(NULL, &bufferPtr, (long) publicKey.size());
	RSA*key = d2i_RSAPublicKey(NULL, &bufferPtr, (long)publicKey.size());

    data = digest(data,"md5");//
	unsigned char* signBufferPtr = (unsigned char*) signData.c_str();
	//int result = RSA_verify(NID_sha1WithRSA, (const unsigned char*)data.c_str(), (unsigned int)data.size(), signBufferPtr, (unsigned int)signData.size(), key);//NID_md5
	int result = RSA_verify(NID_md5, (const unsigned char*) data.c_str(),
			(unsigned int) data.size(), signBufferPtr,
			(unsigned int) signData.size(), key);
	if (result == 1) {
		//success
	} else {
		//failure
		ERR_get_error();
	}
	RSA_free(key);
	key = NULL;

	return result == 1 ? true : false;
}


bool OpensslWapper::verifySha1(std::string publicKey, std::string& data, std::string& signData)
{
    const unsigned char* bufferPtr = (const unsigned char*) publicKey.c_str();
    //RSA*key = d2i_RSA_PUBKEY(NULL, &bufferPtr, (long) publicKey.size());
    RSA*key = d2i_RSAPublicKey(NULL, &bufferPtr, (long)publicKey.size());
    
    data = digest(data,"sha1");//
    unsigned char* signBufferPtr = (unsigned char*) signData.c_str();
    //int result = RSA_verify(NID_sha1WithRSA, (const unsigned char*)data.c_str(), (unsigned int)data.size(), signBufferPtr, (unsigned int)signData.size(), key);//NID_md5
    int result = RSA_verify(NID_sha1, (const unsigned char*) data.c_str(),
                            (unsigned int) data.size(), signBufferPtr,
                            (unsigned int) signData.size(), key);
    if (result == 1) {
        //success
    } else {
        //failure
        ERR_get_error();
    }
    RSA_free(key);
    key = NULL;
    
    return result == 1 ? true : false;
    
}


/* int main(int argc, char* argv[]) {
 string publicKey;
 string privateKey;
 cout << "1" << endl;
 generateRSAKey(1024, publicKey, privateKey);
 cout << "privateKey:" << encode(privateKey) << endl;
 cout << "publicKey:" << encode(publicKey) << endl;
 cout << "2" << endl;
 string data = "xuefli";
 string signData;
 cout << "3" << " " << data.size() <<endl;
 sign(privateKey, data, signData);
 cout << "signData:" << encode(signData) << endl;
 cout << "4" << endl;
 data = "xuefli";
 verify(publicKey, data, signData);
 return 0;
 }*/

bool OpensslWapper::encrypt(const std::string& keyInfor, const std::string& data,
		std::string& encrytData) {
	//Log::debug(TAG, "OpensslWapper::encrypt with key size=[%d] = [%s]", keyInfor.size(), keyInfor.c_str());
	bool ret = true;
	size_t pos = keyInfor.find_first_of("$");
	std::string iv = keyInfor.substr(0, pos);
	std::string key = keyInfor.substr(pos + 1);
	//Log::debug(TAG, "pos = [%d]", pos);
	//Log::debug(TAG, "iv size = [%d] iv = [%s]", iv.size(), iv.c_str());
	//Log::debug(TAG, "key size = [%d] key = [%s]", key.size(), key.c_str());

	unsigned char* outbuf = (unsigned char *) malloc(
			data.size() + EVP_MAX_IV_LENGTH);
	int outlen, tmplen;

	const EVP_CIPHER* type = NULL;
	//type = EVP_des_ede3_cbc();
	//type = EVP_aes_128_cbc();
	//type = EVP_aes_192_cbc();
	//type = EVP_aes_256_cbc();
//	if (iv.size() == IV_64 && key.size() == KEY_192) {
//		type = EVP_des_ede3_cbc();
//	} else if (iv.size() == IV_128) {
//		if (key.size() == KEY_128) {
//			type = EVP_aes_128_cbc();
//		} else if (key.size() == KEY_192) {
//			type = EVP_aes_192_cbc();
//		} else if (key.size() == KEY_256) {
//			type = EVP_aes_256_cbc();
//			//Log::error(TAG, "AES key_size is KEY_256");
//		} else {
//			free(outbuf);
//			//Log::error(TAG, "AES key_size match error or iv_size match error");
//			return false;
//		}
//	} else {
//		free(outbuf);
//		//Log::error(TAG, "key_size match error or iv_size match error");
//		return false;
//	}
    
    if (iv.size() == 8 && key.size() == 24) {
        type = EVP_des_ede3_cbc();
    } else if (iv.size() == 16) {
        if (key.size() == 16) {
            type = EVP_aes_128_cbc();
        } else if (key.size() == 24) {
            type = EVP_aes_192_cbc();
        } else if (key.size() == 32) {
            type = EVP_aes_256_cbc();
            //Log::error(TAG, "AES key_size is KEY_256");
        } else {
            free(outbuf);
            //Log::error(TAG, "AES key_size match error or iv_size match error");
            return false;
        }
    } else {
        free(outbuf);
        //Log::error(TAG, "key_size match error or iv_size match error");
        return false;
    }
    
	EVP_CIPHER_CTX ctx;
	EVP_CIPHER_CTX_init(&ctx);
	EVP_EncryptInit_ex(&ctx, type, NULL, (const unsigned char *) key.c_str(),
			(const unsigned char *) iv.c_str());
//	cout << "block_size " << EVP_CIPHER_CTX_block_size((const EVP_CIPHER_CTX*)&ctx) << endl;
//	cout << "key_length " << EVP_CIPHER_CTX_key_length((const EVP_CIPHER_CTX*)&ctx) << endl;
//	cout << "iv_length " << EVP_CIPHER_CTX_key_length((const EVP_CIPHER_CTX*)&ctx) << endl;
	if (!EVP_EncryptUpdate(&ctx, outbuf, &outlen,
			(const unsigned char *) data.c_str(), data.size())) {
		free(outbuf);
		/* Error */
		//Log::error(TAG, "EVP_EncryptUpdate");
		return 0;
	}

	/* Buffer passed to EVP_EncryptFinal() must be after data just
	 * encrypted to avoid overwriting it.
	 */
	if (!EVP_EncryptFinal_ex(&ctx, outbuf + outlen, &tmplen)) {
		free(outbuf);
		/* Error */
		//Log::error(TAG, "EVP_EncryptFinal_ex");
		return 0;
	}

	outlen += tmplen;
	EVP_CIPHER_CTX_cleanup(&ctx);
	//Log::error(TAG, "outbuf %s", outbuf);
	//Log::error(TAG, "outbuf lenth%d", data.size() + EVP_MAX_IV_LENGTH);

	encrytData.assign(outbuf, outbuf + outlen);
	//Log::error(TAG, "Base64::encode(encrytData)==%s ",
			Base64::encode(encrytData).c_str();
	free(outbuf);
	outbuf = NULL;
//	cout << "originalData's length " << data.size() << " " << data << endl;
//	cout << "encryptData's length " << encrytData.size() << " " << Base64::encode(encrytData) << endl;
	return ret;
}

bool OpensslWapper::decrypt(const std::string& keyInfor, const std::string& data,
		std::string& decrytData) {
	//Log::debug(TAG, "OpensslWapper::decrypt with key size=[%d] = [%s]", keyInfor.size(), keyInfor.c_str());
	bool ret = true;
	size_t pos = keyInfor.find_first_of("$");
	std::string iv = keyInfor.substr(0, pos);
	std::string key = keyInfor.substr(pos + 1);
//	cout << "pos " << pos << endl;
//	cout << "key " << key << " size " << key.size() << endl;
//	cout << "iv " << iv << " size " << iv.size() << endl;
	//Log::debug(TAG, "pos = [%d]", pos);
	//Log::debug(TAG, "iv size = [%d] iv = [%s]", iv.size(), iv.c_str());
	//Log::debug(TAG, "key size = [%d] key = [%s]", key.size(), key.c_str());

	unsigned char* outbuf = (unsigned char *) malloc(
			data.size() + EVP_MAX_IV_LENGTH);
	int outlen, tmplen;

	const EVP_CIPHER* type = NULL;
	//type = EVP_des_ede3_cbc();
	//type = EVP_aes_128_cbc();
	//type = EVP_aes_192_cbc();
	//type = EVP_aes_256_cbc();
//	if (iv.size() == IV_64 && key.size() == KEY_192) {
//		type = EVP_des_ede3_cbc();
//	} else if (iv.size() == IV_128) {
//		if (key.size() == KEY_128) {
//			type = EVP_aes_128_cbc();
//		} else if (key.size() == KEY_192) {
//			type = EVP_aes_192_cbc();
//		} else if (key.size() == KEY_256) {
//			type = EVP_aes_256_cbc();
//		} else {
//			free(outbuf);
////        	cout << "AES key_size match error or iv_size match error" << endl;
//			//Log::error(TAG, "AES key_size match error or iv_size match error");
//			return false;
//		}
//	} else {
//		free(outbuf);
////    	cout << "key_size match error or iv_size match error" << endl;
//		//Log::error(TAG, "key_size match error or iv_size match error");
//		return false;
//	}
    printf("iv size %lu key size %lu",iv.size(),key.size());
    if (iv.size() == 8 && key.size() == 24) {
        type = EVP_des_ede3_cbc();
    } else if (iv.size() == 16) {
        if (key.size() == 16) {
            type = EVP_aes_128_cbc();
        } else if (key.size() == 24) {
            type = EVP_aes_192_cbc();
        } else if (key.size() == 32) {
            type = EVP_aes_256_cbc();
        } else {
            free(outbuf);
            //        	cout << "AES key_size match error or iv_size match error" << endl;
            //Log::error(TAG, "AES key_size match error or iv_size match error");
            return false;
        }
    } else {
        free(outbuf);
        //    	cout << "key_size match error or iv_size match error" << endl;
        //Log::error(TAG, "key_size match error or iv_size match error");
        return false;
    }
    
	EVP_CIPHER_CTX ctx;
	EVP_CIPHER_CTX_init(&ctx);
	EVP_DecryptInit_ex(&ctx, type, NULL, (const unsigned char *) key.c_str(),
			(const unsigned char *) iv.c_str());
//	cout << "block_size " << EVP_CIPHER_CTX_block_size((const EVP_CIPHER_CTX*)&ctx) << endl;
//	cout << "key_length " << EVP_CIPHER_CTX_key_length((const EVP_CIPHER_CTX*)&ctx) << endl;
//	cout << "iv_length " << EVP_CIPHER_CTX_key_length((const EVP_CIPHER_CTX*)&ctx) << endl;
	if (!EVP_DecryptUpdate(&ctx, outbuf, &outlen,
			(const unsigned char *) data.c_str(), data.size())) {
		free(outbuf);
		/* Error */
		//Log::error(TAG, "EVP_DecryptUpdate");
		return 0;
	}

	/* Buffer passed to EVP_EncryptFinal() must be after data just
	 * encrypted to avoid overwriting it.
	 */
	if (!EVP_DecryptFinal_ex(&ctx, outbuf + outlen, &tmplen)) {
		free(outbuf);
		/* Error */
		//Log::error(TAG, "EVP_DecryptFinal_ex");
		return 0;
	}

	outlen += tmplen;
	EVP_CIPHER_CTX_cleanup(&ctx);

	decrytData.assign(outbuf, outbuf + outlen);
	free(outbuf);
	outbuf = NULL;
//	cout << "originalData's length " << data.size() << " " << data << endl;
//	cout << "decryptData's length " << decrytData.size() << " " << decrytData << endl;
	return ret;
}

std::string OpensslWapper::desede(const std::string& secKey, bool encryptFlag,
		const std::string& source) {
	std::string resultData;
	if (encryptFlag == true) {
		encrypt(secKey, source, resultData);
	} else {
		decrypt(secKey, source, resultData);
	}

	return resultData;
}

std::string OpensslWapper::aes(const std::string& secKey, bool encryptFlag,
		const std::string& source) {
	std::string resultData;
	if (encryptFlag == true) {
		encrypt(secKey, source, resultData);
	} else {
		decrypt(secKey, source, resultData);
	}
	//Log::error(TAG, "aes Base64::encode(encrytData)==%s ", resultData.c_str());
	return resultData;
}

void OpensslWapper::symmetricEncodeInit(const std::string& secKey,bool encryptFlag)
{
    EVP_CIPHER_CTX_init(&updateCtx);
    
    const EVP_CIPHER* type = NULL;
    size_t pos = secKey.find_first_of("$");
    std::string iv = secKey.substr(0, pos);
    std::string key = secKey.substr(pos + 1);
    if (iv.size() == 8 && key.size() == 24) {
        type = EVP_des_ede3_cbc();
    } else if (iv.size() == 16) {
        if (key.size() == 16) {
            type = EVP_aes_128_cbc();
        } else if (key.size() == 24) {
            type = EVP_aes_192_cbc();
        } else if (key.size() == 32) {
            type = EVP_aes_256_cbc();
        } else {
            return ;
        }
    } else {
        return ;
    }
    
    if (encryptFlag)
    {
        EVP_EncryptInit_ex(&updateCtx, type, NULL, (const unsigned char *) key.c_str(),
                           (const unsigned char *) iv.c_str());
    }
    else
    {
        EVP_DecryptInit_ex(&updateCtx, type, NULL, (const unsigned char *) key.c_str(),
                           (const unsigned char *) iv.c_str());
    }
}

std::string OpensslWapper::symmetricEncodeUpdate(const std::string& source,bool encryptFlag) {
    std::string resultData;
    
    
    unsigned char* outbuf = (unsigned char *) malloc(source.size() + EVP_MAX_IV_LENGTH);
    int outlen;
    if (encryptFlag)
    {
        if (!EVP_EncryptUpdate(&updateCtx, outbuf, &outlen,(const unsigned char *) source.c_str(), source.size())) {
//            free(outbuf);
//            return 0;
        }
    }
    else
    {
        if (!EVP_DecryptUpdate(&updateCtx, outbuf, &outlen,(const unsigned char *) source.c_str(), source.size())) {
//            free(outbuf);
//            return 0;
        }
    }
    resultData.assign(outbuf, outbuf + outlen);
    
    Base64::encode(resultData).c_str();
    free(outbuf);
    outbuf = NULL;
    
    return resultData;
}

std::string OpensslWapper::symmetricEncodeFinish(bool encryptFlag) {
    std::string resultData;
    unsigned char* outbuf = (unsigned char *) malloc(EVP_MAX_IV_LENGTH);
    int outlen;
    if (encryptFlag)
    {
        if (!EVP_EncryptFinal_ex(&updateCtx, outbuf, &outlen)) {
//            free(outbuf);
//            return 0;
        }
    }
    else
    {
        if (!EVP_DecryptFinal_ex(&updateCtx, outbuf, &outlen)) {
//            free(outbuf);
//            return 0;
        }
    }
    
    
    resultData.assign(outbuf, outbuf + outlen);
    Base64::encode(resultData).c_str();
    EVP_CIPHER_CTX_cleanup(&updateCtx);
    
    free(outbuf);
    outbuf = NULL;
    
    return resultData;
}

std::string OpensslWapper::checkCertExpire(const std::string& certData)
{
    std::string resultData;
    const unsigned char* bufferPtr = (const unsigned char*) certData.c_str();
    X509 *certificateX509 = d2i_X509(NULL, &bufferPtr, (long)certData.length());
    //NSString *issuer = nil;
    if (certificateX509 != NULL) {
        if (certificateX509 != NULL) {
            ASN1_TIME *certificateExpiryASN1 = X509_get_notAfter(certificateX509);
            if (certificateExpiryASN1 != NULL) {
                ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
                if (certificateExpiryASN1Generalized != NULL) {
                    unsigned char *certificateExpiryData = ASN1_STRING_data(certificateExpiryASN1Generalized);
                    int len= ASN1_STRING_length(certificateExpiryASN1Generalized);
                    resultData.assign(certificateExpiryData, certificateExpiryData + len);
                }
            }
        }
    }
    return resultData;
}

//



std::string OpensslWapper::MD5(const std::string& content) {
	unsigned char md[MD5_DIGEST_LENGTH + 1] = { 0 };
	const char* ptrSrc = content.c_str();
	size_t srcLen = content.length();
	EVP_Digest(ptrSrc, srcLen, md, NULL, EVP_md5(), NULL);

	char hex[MD5_DIGEST_LENGTH * 2 + 1] = { 0 };
	for (int i = 0; i < MD5_DIGEST_LENGTH; i++) {
		sprintf(&(hex[i * 2]), "%02X", md[i]);
	}
	std::string dest = hex;
	return dest;
}

std::string OpensslWapper::md5(const std::string& content) {
	unsigned char md[MD5_DIGEST_LENGTH] = { 0 };
	const char* ptrSrc = content.c_str();
	size_t srcLen = content.length();
	EVP_Digest(ptrSrc, srcLen, md, NULL, EVP_md5(), NULL);

	std::string dest;
	dest.assign(md, md + MD5_DIGEST_LENGTH);

	return dest;
}

std::string OpensslWapper::sha1(const std::string& content) {
	unsigned char md[SHA_DIGEST_LENGTH] = { 0 };
	const char* ptrSrc = content.c_str();
	size_t srcLen = content.length();
	EVP_Digest(ptrSrc, srcLen, md, NULL, EVP_sha1(), NULL);

	std::string dest;
	dest.assign(md, md + SHA_DIGEST_LENGTH);

	return dest;
}

std::string OpensslWapper::digest(const std::string& content,const char * algo) {
	int length=0;
	const EVP_MD * engine = NULL;
		if (strcasecmp("sha512", algo) == 0) {
			engine = EVP_sha512();
			length=SHA512_DIGEST_LENGTH;
		} else if (strcasecmp("sha256", algo) == 0) {
			engine = EVP_sha256();
			length=SHA256_DIGEST_LENGTH;

		} else if (strcasecmp("sha1", algo) == 0) {
			engine = EVP_sha1();
			length=SHA_DIGEST_LENGTH;

		} else if (strcasecmp("md5", algo) == 0) {
			engine = EVP_md5();
			length=MD5_DIGEST_LENGTH;

		} else if (strcasecmp("sha224", algo) == 0) {
			engine = EVP_sha224();
			length=SHA224_DIGEST_LENGTH;

		} else if (strcasecmp("sha384", algo) == 0) {
			engine = EVP_sha384();
			length=SHA384_DIGEST_LENGTH;

		} else {
			length=0;
			//Log::error(TAG, "Algorithm [%s] is not supported by this program!",
//					algo;
			ERR_get_error();
		}
	unsigned char *md =(unsigned char*) malloc(
			sizeof(unsigned char) * length);
	const char* ptrSrc = content.c_str();
	size_t srcLen = content.length();
	EVP_Digest(ptrSrc, srcLen, md, NULL, engine, NULL);

	std::string dest;
	dest.assign(md, md + length);

	return dest;
}
std::string OpensslWapper::hex(std::string& content) {
	char *ptr0 = (char*) malloc(2 * content.length() + 1);
	const char *ptr1 = content.c_str();
	int len = content.length();
	for (int i = 0; i < len; i++) {
		sprintf(ptr0 + 2 * i, "%02X", *(ptr1 + i));
	}
	ptr0[2 * len] = '\0';
	std::string dest(ptr0, ptr0 + 2 * len);
	free(ptr0);
	return dest;
}

std::string OpensslWapper::randContent(int length) {
	unsigned char* bufferPtr = (unsigned char*) malloc(
			sizeof(unsigned char) * length);
	RAND_pseudo_bytes(bufferPtr, length);
	std::string content(bufferPtr, bufferPtr + length);

	free(bufferPtr);
	bufferPtr = NULL;

	return content;
}


//std::string OpensslWapper::encode_RSA_publicKey1(const std::string& publicKey,
//		unsigned char* data) {
//
//	const unsigned char* bufferPtr = (const unsigned char*) publicKey.c_str();
//    long keyLen=(long) publicKey.length();
//	RSA*key = d2i_RSAPublicKey(NULL, &bufferPtr, (long) publicKey.length());
//	//RSA*key = d2i_RSA_PUBKEY(NULL, &bufferPtr, (long) publicKey.length());
//
//	int result;
//	std::string strRet;
//
//	if (key != NULL) {
//		int nLen = RSA_size(key);
//		//Log::error(TAG,
//				//"encode_RSA_publicKey**********nLen==*******************[%d]",
//				//nLen);
//		char* pEncode = new char[nLen + 1];
//		result = RSA_public_encrypt((int)strlen(data), data,
//				(unsigned char*) pEncode, key, RSA_PKCS1_PADDING);
//		//Log::error(TAG, "encode result==*******************[%d]",result);
//
//		if (result >= 0) {
//            strRet = std::string(pEncode, result);
//		} else {
//			strRet = "encode_RSA error";
//
//		}
//
//	} else {
//		strRet = "encode_RSA error";
//	}
//	RSA_free(key);
//	CRYPTO_cleanup_all_ex_data();
//	return strRet;
//
//}

std::string OpensslWapper::encode_RSA_publicKey(const std::string& publicKey,
                                                const std::string& data) {
    
    const unsigned char* bufferPtr = (const unsigned char*) publicKey.c_str();
    RSA*key = d2i_RSAPublicKey(NULL, &bufferPtr, (long) publicKey.length());//用这个就可以加密？
    //RSA*key = d2i_RSA_PUBKEY(NULL, &bufferPtr, (long) publicKey.length());
    //std::count<<"publicKey: "<<publicKey<<std::endl;
    //printf("publicKey : %s \n",publicKey.c_str());
    
    int result;
    std::string strRet;
    
    if (key != NULL) {
        int nLen = RSA_size(key);
        //Log::error(TAG,
        //"encode_RSA_publicKey**********nLen==*******************[%d]",
        //nLen);
        char* pEncode = new char[nLen+1];
        result = RSA_public_encrypt(data.length(), (const unsigned char*) data.c_str(),
                                    (unsigned char*) pEncode, key, RSA_PKCS1_PADDING);
        //Log::error(TAG, "encode result==*******************[%d]",result);
        if (result >= 0) {
            strRet = std::string(pEncode, result);
        } else {
            strRet = "encode_RSA error";
            
        }
        
    } else {
        strRet = "encode_RSA error";
    }
    RSA_free(key);
    CRYPTO_cleanup_all_ex_data();
    return strRet;
    
}


std::string OpensslWapper::decode_RSA_privateKey(const std::string& privateKey,
		const std::string& data) {
	const unsigned char* bufferPtr = (const unsigned char*) privateKey.c_str();
	RSA* key = d2i_RSAPrivateKey(NULL, &bufferPtr, (long) privateKey.length());

	int result;
	std::string strRet;

	if (key != NULL) {
		int nLen = RSA_size(key);
		//Log::error(TAG,
				//"decode_RSA_privateKey**********nLen==*******************[%d]",
				//nLen);
		char* pEncode = new char[nLen];
        //const unsigned char *datac=(const unsigned char*)data.c_str();
		result = RSA_private_decrypt(data.length(), (const unsigned char*) data.c_str(),
				(unsigned char*) pEncode, key, RSA_PKCS1_PADDING);

		if (result >= 0) {
			//strRet.assign(pEncode, pEncode + nLen + 1);
            //strRet.assign(pEncode, pEncode + nLen);
            strRet = std::string(pEncode, result);

		} else {
			strRet = "decode_RSA error";
		}

	} else {
		strRet = "decode_RSA_key error";
	}
	RSA_free(key);
	CRYPTO_cleanup_all_ex_data();
	return strRet;
}
int OpensslWapper::HmacEncode(const char * algo, const char * key,
		unsigned int key_length, const char * input, unsigned int input_length,
		unsigned char * &output, unsigned int &output_length) {
	const EVP_MD * engine = NULL;
	if (strcasecmp("sha512", algo) == 0) {
		engine = EVP_sha512();
	} else if (strcasecmp("sha256", algo) == 0) {
		engine = EVP_sha256();
	} else if (strcasecmp("sha1", algo) == 0) {
		engine = EVP_sha1();
	} else if (strcasecmp("md5", algo) == 0) {
		engine = EVP_md5();
	} else if (strcasecmp("sha224", algo) == 0) {
		engine = EVP_sha224();
	} else if (strcasecmp("sha384", algo) == 0) {
		engine = EVP_sha384();
	} else {
		//Log::error(TAG, "Algorithm [%s] is not supported by this program!",
				//algo);

		return -1;
	}

	output = (unsigned char*) malloc(EVP_MAX_MD_SIZE);

	HMAC_CTX ctx;
	HMAC_CTX_init(&ctx);
	HMAC_Init_ex(&ctx, key, strlen(key), engine, NULL);
	HMAC_Update(&ctx, (unsigned char*) input, strlen(input)); // input is OK; &input is WRONG !!!

	HMAC_Final(&ctx, output, &output_length);
	HMAC_CTX_cleanup(&ctx);

	return 0;
}
OpensslWapper::~OpensslWapper() {
}


//自己加的
X509* OpensslWapper::getX509ByString(std::string &certData)
{
    //LPSTR
    const unsigned char* bufferPtr = (const unsigned char*) certData.c_str();
    X509 *certificateX509 = d2i_X509(NULL, &bufferPtr, (long)certData.length());
    return certificateX509;
}



