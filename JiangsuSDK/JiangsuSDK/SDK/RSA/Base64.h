/*
 * Base64 encoding/decoding (RFC1341)
 * Copyright (c) 2005, Jouni Malinen <j@w1.fi>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Alternatively, this software may be distributed under the terms of BSD
 * license.
 *
 * See README and COPYING for more details.
 */

#ifndef BASE64_H
#define BASE64_H
#include <iostream>
//#include "Global.h"

class Base64 {
public:
	Base64();
    //static std::string encodes(std::string stc);
	static std::string encode(std::string src);
    static std::string decode(std::string src);
	//static std::string decode(std::string src);
	static unsigned char * base64_encode(const unsigned char *src, size_t len, size_t *out_len);
	static unsigned char * base64_decode(const unsigned char *src, size_t len, size_t *out_len);
	virtual ~Base64();
};

#endif /* BASE64_H */
