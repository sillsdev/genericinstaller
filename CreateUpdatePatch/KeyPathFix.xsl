<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="../BaseInstallerBuild/KeyPathFix.xsl"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

    <!--
        Everything is inherited from the base stylesheet, deliberately: a patch has
        to describe the very components the base installed, so it must harvest them
        the same way. This file previously restored KeyPath="yes" because buildPatch
        harvested with heat -ag, and the Guid="*" that produces is derived from the
        component's key path. The result was that a patch modelled every file as a
        new component with a different GUID from the base's, so its transform could
        only ever insert components, never modify them. The first patch applied
        cleanly; a second one found its components already inserted by the first,
        marked them Action: Null, and installed nothing. buildPatch now harvests
        with -gg to match the base, so no key path is needed here.
    -->

</xsl:stylesheet>
