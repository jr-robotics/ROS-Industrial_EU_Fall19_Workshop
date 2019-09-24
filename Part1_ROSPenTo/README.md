# ROSPenTo
The Robot Operating System (ROS) penetration testing tool [ROSPenTo](https://github.com/jr-robotics/ROSPenTo) is a software program written in C# which utilizes the missing security in ROS(1) to analyze and manipulte a running ROS network. During the first part of the workshop all security related insufficiencies of ROS(1) are highlighted and the capabilities of ROSPenTo are demonstrated.

You will find the following examples in this document:
 1. [Example ROSPenTo Introduction](#example-rospento-introduction)
 2. [Example ROSPenTo print information about ROS system](#example-rospento-print-information-about-ros-system)
 3. [Example ROSPenTo manipulate ROS topic communication flow](#example-rospento-manipulate-ros-topic-communication-flow)
 4. [Example ROSPenTo isolate a ROS service](#example-rospento-isolate-a-ros-service)
 5. [Example ROSPenTo manipulate a ROS parameter](#example-rospento-manipulate-a-ros-parameter)
 6. [Example ROSPenTo analyse multiple ROS systems](#example-rospento-analyse-multiple-ros-systems)
 7. [Example ROSPenTo inject (malicious) data in ROS topic communication](#example-rospento-inject-malicious-data-in-ros-topic-communication)

## Installation
Perform all the installation steps for ROS and ROSPenTo to be ready for the examples. In the following steps you ```build```, ```create```, ```start``` and ```use``` docker containers for easier environment setup.

### 1. ROSPenTo
The ```docker build``` command builds Docker images from a Dockerfile. This [Dockerfile](Docker_rospento/Dockerfile) is used here. The *-t* option creates a tag for the resulting image. The repository name will be *rospentoimage* and the tag will be *df*.
~~~~
cd Part1_ROSPenTo/Docker_rospento/
docker build -t rospentoimage:df .
~~~~

The ```docker create``` command creates a writeable container layer over the specified image *rospentoimage:df* and prepares it for running the specified command. The *-it* option instructs Docker to create an interactive bash shell in the container. The *--network=host* option shares the host’s networking, and the container does not get its own IP-address assigned. The *--name* option assigns a name (*rospentocontainer*) to the container.
~~~~
docker create -it --network=host --name rospentocontainer rospentoimage:df
~~~~

The ```docker start``` command starts one or more stopped containers.
~~~~
docker start rospentocontainer
~~~~

The ```docker exec``` command runs a new command in a running container. The following command creates a new Bash shell in the container *ros2container*.
~~~~
docker exec -it rospentocontainer bash
~~~~

After the bash is available you should see something similar like:
~~~~
root@pchostname:~#
~~~~

### 2. ROS
Perform the same steps as above but for the ROS docker container:

~~~~
cd Part1_ROSPenTo/Docker_ros/
docker build -t rosimage:df .
~~~~

~~~~
docker create -it --network=host --name roscontainer rosimage:df
~~~~

~~~~
docker start roscontainer
~~~~

~~~~
docker exec -it roscontainer bash
~~~~

### 3. Start ROS system
For the following examples you have to start a ROS master and two communicating nodes. Open a terminal window for each of the following commands. In each terminal window first connect to the docker container (```docker exec -it roscontainer bash```) and then run the command in the container's shell: 

Start a ROS master in the **first** shell:
~~~~
roscore
~~~~

Start the ROS publisher node in the **second** shell:
~~~~
rosrun roscpp_tutorials talker
~~~~

Start the ROS subscriber node in the **third** shell:
~~~~
rosrun roscpp_tutorials listener
~~~~

## Example ROSPenTo Introduction
With a new terminal window you can connect to the ROSPenTo docker container (```docker exec -it rospentocontainer bash```) and start the ROS penetration testing tool (ROSPenTo):

~~~~
rospento
~~~~

After you started ROSPenTo you should see the following output:
~~~~
ROSPenTo - Penetration testing tool for the Robot Operating System (ROS)
Copyright(C) 2018 JOANNEUM RESEARCH Forschungsgesellschaft mbH
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions.
For more details see the GNU General Public License at <http://www.gnu.org/licenses/>.

What do you want to do?
0: Exit
1: Analyse system...
2: Print all analyzed systems
~~~~

### Analyse System
In ROSPenTo, you first have to analyse an existing ROS system. Therefore input ```1``` in the terminal and then enter the URI of the ROS master:
~~~~
http://localhost:11311/
~~~~

After you analysed a new ROS system, you get an overview of the system's components printed. The overview lists all the following ROS elements:
 * Nodes
 * Topics
 * Services
 * Communications (Publisher -> Topic -> Subscriber)
 * Parameters

###### ROSPenTo output of analyed system
~~~~
System 0: http://127.0.0.1:11311/
Nodes:
  Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:45707/)
  Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
  Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:46195/)
Topics:
  Topic 0.0: /chatter (Type: std_msgs/String)
  Topic 0.1: /rosout (Type: rosgraph_msgs/Log)
  Topic 0.2: /rosout_agg (Type: rosgraph_msgs/Log)
Services:
  Service 0.3: /listener/get_loggers
  Service 0.2: /listener/set_logger_level
  Service 0.4: /rosout/get_loggers
  Service 0.5: /rosout/set_logger_level
  Service 0.1: /talker/get_loggers
  Service 0.0: /talker/set_logger_level
Communications:
  Communication 0.0:
    Publishers:
      Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:46195/)
    Topic 0.0: /chatter (Type: std_msgs/String)
    Subscribers:
      Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:45707/)
  Communication 0.1:
    Publishers:
      Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:46195/)
      Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:45707/)
    Topic 0.1: /rosout (Type: rosgraph_msgs/Log)
    Subscribers:
      Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
  Communication 0.2:
    Publishers:
      Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
    Topic 0.2: /rosout_agg (Type: rosgraph_msgs/Log)
    Subscribers:
Parameters:
  Parameter 0.0:
    Name: /roslaunch/uris/host_robl013__43957
  Parameter 0.1:
    Name: /rosdistro
  Parameter 0.2:
    Name: /rosversion
  Parameter 0.3:
    Name: /run_id
~~~~

In the current version of ROSPenTo, you have the following user menu options available:

###### ROSPenTo user menu:
~~~~
What do you want to do?
0: Exit
1: Analyse system...
2: Print all analyzed systems
3: Print information about analyzed system...
4: Print nodes of analyzed system...
5: Print node types of analyzed system (Python or C++)...
6: Print topics of analyzed system...
7: Print services of analyzed system...
8: Print communications of analyzed system...
9: Print communications of topic...
10: Print parameters...
11: Update publishers list of subscriber (add)...
12: Update publishers list of subscriber (set)...
13: Update publishers list of subscriber (remove)...
14: Isolate service...
15: Unsubscribe node from parameter (only C++)...
16: Update subscribed parameter at Node (only C++)...
~~~~

In the following examples the individual options are explained on more detail.

## Example ROSPenTo print information about ROS system
The user menu options 2 to 10 print the system's components in different views and extent. You can also filter the output of ROSPenTo, because the overview can get really big and confusing if the nodes in the ROS system provide much services and communicate a lot.

~~~~
2: Print all analyzed systems
3: Print information about analyzed system...
4: Print nodes of analyzed system...
5: Print node types of analyzed system (Python or C++)...
6: Print topics of analyzed system...
7: Print services of analyzed system...
8: Print communications of analyzed system...
9: Print communications of topic...
10: Print parameters...
~~~~

With the following option you can e.g. just print all existing nodes of the analysed ROS system:

```4: Print nodes of analyzed system...```


After you enter the number of the system you get the following output:
~~~~
System 0: http://127.0.0.1:11311/
Nodes:
  Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:45707/)
  Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
  Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:46195/)
~~~~

## Example ROSPenTo manipulate ROS topic communication flow
With the user menu options 11 to 13 you are able to manipulate the ROS topic communication flow. This means that you can ```add```, ```set``` and ```remove``` one or several publisher from the subscriber's communications.  

~~~~
11: Update publishers list of subscriber (add)...
12: Update publishers list of subscriber (set)...
13: Update publishers list of subscriber (remove)...
~~~~

### Exclude subscriber from receiving topic data
With the following option you can ```remove``` one or more publisher from a subscriber, so the subscriber is no longer receiving messages (belonging to a certain topic) from this publisher.

```13: Update publishers list of subscriber (remove)...```

First, this option asks to select the particular subscriber.
~~~~
To which subscriber do you want to send the publisherUpdate message?
Please enter number of subscriber (e.g.: 0.0):
~~~~
Enter the number of the subscriber.

Then you have to select the ROS topic
~~~~
Which topic should be affected?
Please enter number of topic (e.g.: 0.0):
~~~~
Enter the number of the topic.

Finally you have to define the publisher(s) which you want to remove:
~~~~
Which publisher(s) do you want to remove?
Please enter number of publisher(s) (e.g.: 0.0,0.1,...):
~~~~
Enter the number of one or more publisher(s), separated by commas.

If you entered valid numbers, you should see the following output (the XmlRpcUri can vary)
~~~~
sending publisherUpdate to subscriber '/listener (XmlRpcUri: http://127.0.0.1:45707/)' over topic '/chatter (Type: std_msgs/String)' with publishers ''
PublisherUpdate completed successfully.
~~~~

Now, the subscriber should have **stopped** printing message data because it do not receive messages of the topic */chatter* any more.


## Example ROSPenTo isolate a ROS service
With the following option you can make a ROS service unavailable although the ROS service node is still running.

```14: Isolate service...```

First start a node providing a service:
~~~~
rosrun roscpp_tutorials add_two_ints_server
~~~~

Now any other node in the ROS system is able to use the service:
~~~~
rosrun roscpp_tutorials add_two_ints_client 1 2
~~~~
And the result is printed:
>Sum: 3

**After you have changed something in the ROS system (e.g. new node started) you have to analyse the RSO system again.**

If you perform the ```14: Isolate service...``` procedure and choose the correct serive, no ROS node can use the service any more:
~~~~
rosrun roscpp_tutorials add_two_ints_client 1 2
~~~~

Output:
>Failed to call service add_two_ints


## Example ROSPenTo manipulate a ROS parameter
With the user menu options 15 and 16 you are able to manipulate the ROS parameters of interest of a node.

With the following option you can make changes of a ROS parameter unnoticeable for a respective node.
~~~~
15: Unsubscribe node from parameter (only C++)...
~~~~

With the following option you can send a new value of a ROS parameter to a node. 
~~~~
16: Update subscribed parameter at Node (only C++)...
~~~~

## Example ROSPenTo analyse multiple ROS systems

### Start another ROS system
To analyse multiple ROS systems, you have to start multiple ROS masters and corresponding ROS nodes.

First, open **three** additional terminal windows and connect all of them to the already running docker container:
~~~~
docker exec -it roscontainer bash
~~~~

Start a ROS master with different port number in the **first** shell:
~~~~
roscore -p 11312
~~~~

Set the new ROS master URI and start the ROS publisher node in the **second** shell:
~~~~
export ROS_MASTER_URI=http://localhost:11312
rosrun roscpp_tutorials talker
~~~~

Set the new ROS master URI and start the ROS subscriber node in the **third** shell:
~~~~
export ROS_MASTER_URI=http://localhost:11312
rosrun roscpp_tutorials listener
~~~~

### Analyse and print all systems
You have to perform the ```1: Analyse system...``` step for every running ROS system which you want to investigate:
~~~~
http://localhost:11311/
http://localhost:11312/
~~~~

If you print all analysed systems with the option ```2: Print all analyzed systems``` you will get the following output:
~~~~
Analysed Systems:
System 0: http://127.0.0.1:11311/
System 1: http://127.0.0.1:11312/
~~~~


## Example ROSPenTo inject (malicious) data in ROS topic communication
Suppose we have the following two ROS systems running with a */talker* publisher and a */listener* subscriber node in each system. Imagine system 0 is a productive ROS application and system 1 is setup und utilized by an attacker which want to inject malicious data in the productive system. The publisher node *Node 1.0: /talker* of the attacker's system is producing manipulated data on topic */chatter* and it should be sent to the victim node *Node 0.1: /listener*.

~~~~
System 0: http://127.0.0.1:11311/
Nodes:
  Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:44121/)
  Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
  Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:35171/)
Topics:
  Topic 0.0: /chatter (Type: std_msgs/String)
  Topic 0.1: /rosout (Type: rosgraph_msgs/Log)
  Topic 0.2: /rosout_agg (Type: rosgraph_msgs/Log)
Services:
  Service 0.3: /listener/get_loggers
  Service 0.2: /listener/set_logger_level
  Service 0.4: /rosout/get_loggers
  Service 0.5: /rosout/set_logger_level
  Service 0.1: /talker/get_loggers
  Service 0.0: /talker/set_logger_level
Communications:
  Communication 0.0:
    Publishers:
      Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:35171/)
    Topic 0.0: /chatter (Type: std_msgs/String)
    Subscribers:
      Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:44121/)
  Communication 0.1:
    Publishers:
      Node 0.0: /talker (XmlRpcUri: http://127.0.0.1:35171/)
      Node 0.1: /listener (XmlRpcUri: http://127.0.0.1:44121/)
    Topic 0.1: /rosout (Type: rosgraph_msgs/Log)
    Subscribers:
      Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
  Communication 0.2:
    Publishers:
      Node 0.2: /rosout (XmlRpcUri: http://127.0.0.1:40375/)
    Topic 0.2: /rosout_agg (Type: rosgraph_msgs/Log)
    Subscribers:
Parameters:
  Parameter 0.0:
    Name: /roslaunch/uris/host_robl013__43957
  Parameter 0.1:
    Name: /rosdistro
  Parameter 0.2:
    Name: /rosversion
  Parameter 0.3:
    Name: /run_id
~~~~

~~~~
System 1: http://127.0.0.1:11312/
Nodes:
  Node 1.1: /listener (XmlRpcUri: http://127.0.0.1:40565/)
  Node 1.2: /rosout (XmlRpcUri: http://127.0.0.1:39573/)
  Node 1.0: /talker (XmlRpcUri: http://127.0.0.1:39821/)
Topics:
  Topic 1.0: /chatter (Type: std_msgs/String)
  Topic 1.1: /rosout (Type: rosgraph_msgs/Log)
  Topic 1.2: /rosout_agg (Type: rosgraph_msgs/Log)
Services:
  Service 1.3: /listener/get_loggers
  Service 1.2: /listener/set_logger_level
  Service 1.4: /rosout/get_loggers
  Service 1.5: /rosout/set_logger_level
  Service 1.1: /talker/get_loggers
  Service 1.0: /talker/set_logger_level
Communications:
  Communication 1.0:
    Publishers:
      Node 1.0: /talker (XmlRpcUri: http://127.0.0.1:39821/)
    Topic 1.0: /chatter (Type: std_msgs/String)
    Subscribers:
      Node 1.1: /listener (XmlRpcUri: http://127.0.0.1:40565/)
  Communication 1.1:
    Publishers:
      Node 1.0: /talker (XmlRpcUri: http://127.0.0.1:39821/)
      Node 1.1: /listener (XmlRpcUri: http://127.0.0.1:40565/)
    Topic 1.1: /rosout (Type: rosgraph_msgs/Log)
    Subscribers:
      Node 1.2: /rosout (XmlRpcUri: http://127.0.0.1:39573/)
  Communication 1.2:
    Publishers:
      Node 1.2: /rosout (XmlRpcUri: http://127.0.0.1:39573/)
    Topic 1.2: /rosout_agg (Type: rosgraph_msgs/Log)
    Subscribers:
Parameters:
  Parameter 1.0:
    Name: /roslaunch/uris/host_robl013__46159
  Parameter 1.1:
    Name: /rosdistro
  Parameter 1.2:
    Name: /rosversion
  Parameter 1.3:
    Name: /run_id
~~~~


ROSPenTo can be used to perform the described scenario. Therefore, the following user menu option is used:

```12: Update publishers list of subscriber (set)...```

If you enter the correct numbers, the list of publishers is updated on the subscriber node and it receives the malicious data from the attacker's publisher node.

~~~~
To which subscriber do you want to send the publisherUpdate message?
Please enter number of subscriber (e.g.: 0.0):
0.1
Which topic should be affected?
Please enter number of topic (e.g.: 0.0):
0.0
Which publisher(s) do you want to set?
Please enter number of publisher(s) (e.g.: 0.0,0.1,...):
1.0 
sending publisherUpdate to subscriber '/listener (XmlRpcUri: http://143.224.167.14:44121/)' over topic '/chatter (Type: std_msgs/String)' with publishers '/talker (XmlRpcUri: http://143.224.167.14:39821/)'
PublisherUpdate completed successfully.
~~~~






























