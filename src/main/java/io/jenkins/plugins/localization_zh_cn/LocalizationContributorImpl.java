package io.jenkins.plugins.localization_zh_cn;

import edu.umd.cs.findbugs.annotations.NonNull;
import hudson.Extension;
import hudson.PluginWrapper;
import hudson.init.InitMilestone;
import hudson.init.Initializer;
import io.jenkins.plugins.localization.support.LocalizationContributor;

import edu.umd.cs.findbugs.annotations.CheckForNull;
import java.net.URL;
import org.jvnet.localizer.ResourceBundleHolder;
import org.jvnet.localizer.ResourceProvider;

@Extension
public class LocalizationContributorImpl extends LocalizationContributor {

    /**
     * The localization-support plugin installs its ResourceProvider after JOB_LOADED. Core Messages classes can be
     * initialized before then and retain an English bundle for the life of the JVM, so make the Chinese resources
     * available before that first lookup.
     */
    @Initializer(after = InitMilestone.EXTENSIONS_AUGMENTED, before = InitMilestone.JOB_LOADED)
    public static void installEarlyResourceProvider() {
        ResourceProvider.setProvider(new EarlyResourceProvider());
        ResourceBundleHolder.clearCache();
    }

    @CheckForNull
    @Override
    public URL getResource(@NonNull String s) {
        if (s.startsWith("/")) {
            s = s.substring(1);
        }
        return getClass().getClassLoader().getResource(s);
    }

    @CheckForNull
    @Override
    public URL getPluginResource(@NonNull String s, @NonNull PluginWrapper pluginWrapper) {
        return getClass().getClassLoader().getResource("webapp/" + s);
    }

    private static final class EarlyResourceProvider extends ResourceProvider {
        @CheckForNull
        @Override
        public URL getResource(@NonNull String resource, @NonNull Class<?> type) {
            String resourceName = resource.startsWith("/")
                    ? resource.substring(1)
                    : type.getPackage().getName().replace('.', '/') + "/" + resource;
            URL localized = LocalizationContributorImpl.class.getClassLoader().getResource(resourceName);
            return localized != null ? localized : type.getResource(resource);
        }
    }
}
