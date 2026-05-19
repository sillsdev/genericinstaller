<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="../BaseInstallerBuild/KeyPathFix.xsl"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

    <!-- Override: patches need KeyPath="yes" to keep Guid="*" working -->
    <xsl:template match="@KeyPath[.='yes']">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>
