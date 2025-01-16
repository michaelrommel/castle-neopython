#! /usr/bin/python3

import concurrent.futures
import hashlib
import hmac
import os

secret = os.urandom(32)
long_string = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed quam massa, fringilla a eleifend ac, dictum et erat. Donec malesuada sem in urna rutrum malesuada. Etiam iaculis, enim vitae faucibus venenatis, libero ante auctor dui, id faucibus mauris ipsum ut nulla. Aliquam tempus pharetra ex, nec interdum nisi ultricies nec. Aliquam faucibus felis hendrerit commodo ultrices. Praesent feugiat risus vitae nisl pellentesque pulvinar. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Praesent pharetra metus ut velit fringilla, ut fermentum purus dignissim. Ut placerat finibus arcu. Nulla sed nisi ac quam congue volutpat. Vestibulum tempus tortor vitae arcu posuere eleifend. Vivamus nunc ipsum, sagittis sit amet ultricies sed, dignissim non libero.\n\nSed sed velit nec dolor placerat varius eget in neque. Pellentesque bibendum pulvinar lectus, et dapibus urna tempor eget. Vivamus rutrum consectetur quam sit amet consectetur. Fusce in massa a augue ultricies condimentum id ut augue. In vitae commodo ex. Praesent condimentum nisl et leo lacinia, at bibendum mauris hendrerit. Sed feugiat ipsum nec quam consectetur, aliquam porttitor enim finibus. Vivamus tempor arcu nec quam malesuada, vel cursus orci rhoncus. Proin aliquam vehicula nisi, eget molestie sem hendrerit sit amet. Etiam aliquam magna sed porta rhoncus. Integer varius dapibus eros, eget ornare quam vehicula a. Praesent et mauris tellus. Aliquam lobortis purus arcu, sit amet cursus tortor accumsan et. Integer a auctor sem, ac semper eros.\n\nMorbi at eleifend augue. Maecenas convallis in nisl vel sodales. Suspendisse non rhoncus massa, et posuere diam. Fusce ac diam sit amet felis gravida cursus sit amet quis lorem. Mauris ut luctus erat, eu dignissim tortor. Nunc leo libero, ultrices eu dignissim sit amet, iaculis non lorem. Maecenas sollicitudin pharetra felis. Praesent non tortor faucibus, sodales est id, porta erat. Etiam varius dignissim nisl, a rhoncus urna semper eu. Vestibulum quis fermentum magna, at eleifend justo. Fusce dictum viverra risus id mollis. Sed eget odio lorem. Proin lacus magna, pretium quis commodo cursus, mattis eu enim. Praesent facilisis leo vitae libero mattis maximus. Nulla tristique lorem sed dolor imperdiet, ac ornare est volutpat.\n\nMauris est nibh, malesuada a mauris in, mattis lobortis ante. Mauris at ipsum ante. Vivamus gravida tincidunt mattis. Vivamus ullamcorper, sem vitae dapibus posuere, magna felis ullamcorper massa, id rutrum diam magna ac lacus. Curabitur egestas purus nec tempus mollis. Vestibulum ornare sapien quis eros volutpat, ac euismod tortor ornare. Sed eget lectus vel tellus imperdiet ultrices.".encode(
    "ascii")  # {{{}}}


def do_expensive_hashing(i):
    print("Thread started with id %d" % i)
    for x in range(0, 300000):
        try:
            hd = hmac.digest(secret, long_string, "sha256")
        except Exception as exc:
            print("%r generated an exception: %s" % (i, exc))


with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
    bg_thread_dict = {executor.submit(
        do_expensive_hashing, id): id for id in range(0, 2)}
    for future in concurrent.futures.as_completed(bg_thread_dict):
        print("Thread %d completed" % bg_thread_dict[future])
