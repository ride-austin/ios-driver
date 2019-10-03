<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="1.0">
  <xsl:output omit-xml-declaration="no" indent="yes" />
  <xsl:strip-space elements="*" />

  <xsl:template match="/*">
    <testsuites>
      <xsl:apply-templates select="//dict[key = 'Tests']"/>
    </testsuites>
  </xsl:template>  

  <xsl:template match="//dict[key = 'Tests']">
    <testsuite name="{string[2]}">
      <xsl:apply-templates select="//dict[key = 'Tests']//dict[key = 'TestStatus']"/>
    </testsuite>
  </xsl:template>

  <xsl:template match="//dict[key = 'Tests']//dict[key = 'TestStatus']">
    <testcase classname="{../../string[1]}" name="{string[2]}" status="{string[4]}">
      <xsl:if test="key[2] = 'FailureSummaries'">    
        <failure message="{array/dict/string[2]}">
          <xsl:value-of select="concat(array/dict/string[1], ':', array/dict/integer[1])"/>
          </failure>
      </xsl:if>
    </testcase>
  </xsl:template>
</xsl:stylesheet>