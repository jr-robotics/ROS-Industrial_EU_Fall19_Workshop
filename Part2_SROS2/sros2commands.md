### Create keystore

~~~~
ros2 security create_keystore keystore
~~~~

The ```create_keystore``` command performs the following steps (See the [API implementation](https://github.com/ros2/sros2/blob/dashing/sros2/sros2/api/__init__.py)):
 1. Creates a directory called '*keystore*'
 2. Creates a [config file](ExampleFiles/ca_conf.cnf) for the certificate authority (CA)
 3. Creates a parameter file for the ECDSA (Elliptic Curve Digital Signature Algorithm)
 4. Creates a new EC private key for the CA. The key is **not encrypted**!
 5. Creates a self signed certificate for use as root CA
 6. Creates a signed governance file
 7. Creates a *serial* and an *index* file

Output:
~~~~
creating directory: keystore
creating CA file: keystore/ca_conf.cnf
creating ECDSA param file: keystore/ecdsaparam
running command in path [None]: openssl ecparam -name prime256v1 > keystore/ecdsaparam
creating new CA key/cert pair
running command in path [None]: openssl req -nodes -x509 -days 3650 -newkey ec:keystore/ecdsaparam -keyout keystore/ca.key.pem -out keystore/ca.cert.pem -config keystore/ca_conf.cnf
Generating an EC private key
writing new private key to 'keystore/ca.key.pem'
-----
creating governance file: keystore/governance.xml
creating signed governance file: keystore/governance.p7s
running command in path [None]: openssl smime -sign -in keystore/governance.xml -text -out keystore/governance.p7s -signer keystore/ca.cert.pem -inkey keystore/ca.key.pem
all done! enjoy your keystore in keystore
cheers!
~~~~
The [openssl](#openssl) commands are described at the end of this document.

### Create key(s)
For every ros2 node key files must be generated. The following section shows how the key files are generated for the *minimal_publisher* example node. The name of the node is */minimal_publisher* and defined in the source code.

~~~~
ros2 security create_key keystore /minimal_publisher
~~~~

The ```create_key``` command performs the following steps (See the [API implementation](https://github.com/ros2/sros2/blob/dashing/sros2/sros2/api/__init__.py)):
 1. Creates a parameter file for the ECDSA
 2. Creates a [config file](ExampleFiles/request.cnf) for a certificate request
 3. Generates a new certificate request
 4. Creates a new EC private key for the specified ROS2 node. The key is **not encrypted**!
 5. Creates and signs the node certificate based on CA certificate
 6. Creates and signs the permissions file

Output:
~~~~
creating key for identity: '/minimal_publisher'
creating ECDSA param file: keystore/minimal_publisher/ecdsaparam
running command in path [None]: openssl ecparam -name prime256v1 > keystore/minimal_publisher/ecdsaparam
creating key and cert request
running command in path [keystore]: openssl req -nodes -new -newkey ec:minimal_publisher/ecdsaparam -config minimal_publisher/request.cnf -keyout minimal_publisher/key.pem -out minimal_publisher/req.pem
Generating an EC private key
writing new private key to 'minimal_publisher/key.pem'
-----
creating cert
running command in path [keystore]: openssl ca -batch -create_serial -config ca_conf.cnf -days 3650 -in minimal_publisher/req.pem -out minimal_publisher/cert.pem
Using configuration from ca_conf.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4097 (0x1001)
        Validity
            Not Before: Sep 16 14:17:22 2019 GMT
            Not After : Sep 13 14:17:22 2029 GMT
        Subject:
            commonName                = /minimal_publisher
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
Certificate is to be certified until Sep 13 14:17:22 2029 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated
running command in path [None]: openssl smime -sign -in keystore/minimal_publisher/permissions.xml -text -out keystore/minimal_publisher/permissions.p7s -signer keystore/ca.cert.pem -inkey keystore/ca.key.pem
~~~~

Now, the *keystore* direcotry looks like follows:
~~~~
keystore/
├── 1000.pem
├── 1001.pem
├── ca.cert.pem
├── ca.key.pem
├── ca_conf.cnf
├── ecdsaparam
├── governance.p7s
├── governance.xml
├── index.txt
├── index.txt.attr
├── index.txt.attr.old
├── index.txt.old
├── minimal_publisher
│   ├── cert.pem
│   ├── ecdsaparam
│   ├── governance.p7s
│   ├── identity_ca.cert.pem
│   ├── key.pem
│   ├── permissions.p7s
│   ├── permissions.xml
│   ├── permissions_ca.cert.pem
│   ├── req.pem
│   └── request.cnf
├── minimal_subscriber
│   ├── cert.pem
│   ├── ecdsaparam
│   ├── governance.p7s
│   ├── identity_ca.cert.pem
│   ├── key.pem
│   ├── permissions.p7s
│   ├── permissions.xml
│   ├── permissions_ca.cert.pem
│   ├── req.pem
│   └── request.cnf
├── serial
└── serial.old
~~~~

### List keys

~~~~
ros2 security list_keys keystore/
~~~~

The ```list_keys``` command prints all node keys which are present in the keystore. In detail, the command lists all found subfolders in the keystore directory, no matter if there are keys present or not.

~~~~
minimal_subscriber
minimal_publisher
~~~~

### Distribute keys

The ```distribute_key``` command is not implemented (checked for ROS2 dashing on 17.09.2019). Link to [API](https://github.com/ros2/sros2/blob/dashing/sros2/sros2/api/__init__.py).

~~~~ python
def distribute_key(source_keystore_path, taget_keystore_path):
    raise NotImplementedError()
~~~~

### Generate policy 
~~~~
ros2 security generate_policy policy.xml
~~~~

The ```generate_policy``` command generates a XML policy file from ROS graph data.

The generated *policy.xml* file (based on the minimal publisher and subscriber example) looks like that:
~~~~
<policy version="0.1.0">
  <profiles>
    <profile node="minimal_publisher" ns="/"/>
    <profile node="minimal_subscriber" ns="/"/>
  </profiles>
</policy>
~~~~

### Create permission
~~~~
ros2 security create_permission keystore /minimal_publisher keystore/minimal_publisher/policy.xml
~~~~

The ```create_permission``` command generates a *permissions.xml* file (and a signature of it) based on the *policy.xml*. An example of the created permissions file can be viewed [here](ExampleFiles/permissions.xml). The permissions file specifies the permissions of each node and defines which topic can be published or subscribed.

### Generate artifacts
~~~~
ros2 security generate_artifacts -k keystore/ -n /minimal_publisher -p keystore/minimal_publisher/policy.xml
~~~~

The ```generate_artifacts``` command generate keys and permission files from a list of identities and policy files.


## openssl
ROS2 uses ```openssl``` to create and process certificate requests and to generate relevant (key/certificate) files.

The ```ecparam``` command is used to generate EC parameter files.
~~~~
openssl ecparam -name prime256v1 > keystore/ecdsaparam
~~~~

Explanation of the parameters:
 - -name: Creates EC parameters with the group 'prime256v1'. To learn more about Elliptic
Curve Cryptography name curve, please visit: [Elliptic Curve Cryptography Subject Public Key Information](https://www.ietf.org/rfc/rfc5480.txt)


The ```req``` command primarily creates and processes certificate requests in PKCS#10 format. It can additionally create self signed certificates for use as root CAs for example.
~~~~
openssl req -nodes -x509 -days 3650 -newkey ec:keystore/ecdsaparam -keyout keystore/ca.key.pem -out keystore/ca.cert.pem -config keystore/ca_conf.cnf
~~~~

Explanation of the parameters:
 - -nodes: if this option is specified then if a private key is created it will **not be encrypted**
 - -x509: this option outputs a self signed certificate instead of a certificate request
 - -days: specifies the number of days to certify the certificate for
 - -new: generates a new certificate request
 - -newkey: generates EC key usable both with ECDSA or ECDH algorithms
 - -config: specifies an alternative configuration
 - -keyout: filename to write the newly created private key to
 - -out: specifies the output filename to write to

The ```smime``` command signes messages in *MIME* format.
~~~~
openssl smime -sign -in keystore/governance.xml -text -out keystore/governance.p7s -signer keystore/ca.cert.pem -inkey keystore/ca.key.pem
~~~~

Explanation of the parameters:
 - -sign: signs the input message in *MIME* format
 - -in: the input message
 - -text: adds plain text *MIME* headers to the input message
 - -out:  the output *MIME* format message that has been signed
 - -signer: the signing certificate
 - -inkey: the private key to use for signing

The ```ca``` command is a minimal CA application. It can be used to sign certificate requests in a variety of forms and generate CRLs it also maintains a text database of issued certificates and their status.
~~~~
openssl ca -batch -create_serial -config ca_conf.cnf -days 3650 -in minimal_publisher/req.pem -out minimal_publisher/cert.pem
~~~~

Explanation of the parameters:
 - -batch: sets the batch mode. In this mode no questions will be asked and all certificates will be certified automatically.
 - -create_serial: creates a new random serial to be used as next serial number
 - -config: specifies the configuration file to use
 - -days: the number of days to certify the certificate for
 - -in: an input filename containing a single certificate request to be signed by the CA
 - -out: the output file to output certificates to