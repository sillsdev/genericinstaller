<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@KeyPath[.='yes']">
		<xsl:attribute name="KeyPath">
			<xsl:value-of select="'yes'"/>
		</xsl:attribute>
		<xsl:attribute name="TrueType">
			<xsl:value-of select="'yes'"/>
		</xsl:attribute>
	</xsl:template>
<!--
The following should work but do not.
	<xsl:template match="File">
		<File TrueType="yes">
			<xsl:apply-templates select="@*|node()" />
		</File>
	</xsl:template>

	<xsl:template match="File">
		<File>
			<xsl:attribute name="TrueType">
				<xsl:value-of select="'yes'" />
			</xsl:attribute>
			<xsl:apply-templates select="@*|node()" />
		</File>
	</xsl:template>
	<xsl:template match="*[@Source[ends-with(.,'.ttf')]]">
		<File TrueType="yes">
			<xsl:apply-templates select="@*|node()" />
		</File>
	</xsl:template>
	-->
</xsl:stylesheet>