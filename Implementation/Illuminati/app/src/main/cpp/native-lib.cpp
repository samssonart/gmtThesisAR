#include <jni.h>
#include <string>
#include <sstream>

extern "C"
{
    JNIEXPORT jstring JNICALL
    Java_com_illuminati_samssonart_illuminati_MainActivity_stringFromJNI(JNIEnv *env,
                                                                         jobject /* this */) {

        std::string hello = "Hello from C++";
        return env->NewStringUTF(hello.c_str());

    }

    JNIEXPORT jstring JNICALL
    Java_com_illuminati_samssonart_illuminati_MainActivity_sliderChanged(JNIEnv * env , jobject /* this */, jfloat f )
    {

        float fs = f;
        std::ostringstream ss;
        ss << fs;
        std::string s(ss.str());
        std::string hello = "The value is now "+ s;
        return env->NewStringUTF(hello.c_str());


    }
}
