#include <iostream>
#include <zlib.h>
#include <openssl/opensslv.h>

int main() {
    std::cout << "zlib=" << zlibVersion() << " openssl=" << OPENSSL_VERSION_TEXT << "\n";
    return 0;
}
