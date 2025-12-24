############################################
# AGORA
############################################
-keep class io.agora.** { *; }
-dontwarn io.agora.**

############################################
# FLUTTER CALLKIT
############################################
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

############################################
# HYPHENATE PUSH (ROOT CAUSE)
############################################
-keep class com.hyphenate.push.** { *; }
-dontwarn com.hyphenate.push.**

############################################
# OEM PUSH SDKS (OPTIONAL – SAFE TO IGNORE)
############################################
-dontwarn com.heytap.msp.push.**
-dontwarn com.vivo.push.**
-dontwarn com.xiaomi.mipush.**
-dontwarn com.meizu.cloud.pushsdk.**

############################################
# JAVA / ANDROID INTERNAL
############################################
-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry

############################################
# DESUGAR
############################################
-dontwarn com.google.devtools.build.android.desugar.runtime.**
