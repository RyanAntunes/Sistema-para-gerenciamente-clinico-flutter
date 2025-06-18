
## 🛠 Correção do erro de `namespace` no pacote `android_intent_plus`

Durante a build do projeto, pode ocorrer o seguinte erro ao utilizar o pacote `android_intent_plus`:

A failure occurred while executing com.android.build.gradle.internal.res.LinkApplicationAndroidResourcesTask$TaskAction
Android resource linking failed
ERROR: .../android_intent_plus-3.1.9/android/build.gradle: attribute 'android:name' in <application> tag must be a valid Java class name.


### ✅ Solução temporária

Esse problema é causado pela ausência do atributo `namespace` no arquivo `build.gradle` do pacote.

#### Etapas para resolver:

1. **Abra o seguinte arquivo no seu sistema:**

C:\Users\seuUsuario\AppData\Local\Pub\Cache\hosted\pub.dev\android_intent_plus-3.1.9\android\build.gradle


2. **Logo abaixo da linha `android {`**, adicione:

```groovy
namespace 'dev.fluttercommunity.plus.androidintent'

3. O trecho completo ficará assim:

android {
    namespace 'dev.fluttercommunity.plus.androidintent'
    compileSdkVersion 33

    ...
}


⚠️ Aviso: esta correção é temporária. Sempre que atualizar os pacotes do Flutter, o diretório .pub-cache pode ser sobrescrito.