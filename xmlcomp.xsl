<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dyn="http://exslt.org/dynamic"
  xmlns:func="http://exslt.org/functions"
  xmlns:f="http://example.com/f"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="dyn func str"
  version="1.0">

  <xsl:output method="text"/>

  <xsl:strip-space elements="*"/>

  <xsl:param name="strict-positioning"/>
  <xsl:param name="text-diff" select="0"/>
  <xsl:param name="attributes" select="0"/>

  <xsl:variable name="strict-pos" select="str:split($strict-positioning, ',')"/>

  <xsl:variable name="ref" select="document($compare)"/>

  <xsl:template match="/">
    <xsl:apply-templates>
      <xsl:with-param name="base-path"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="@*">
    <xsl:param name="base-path"/>
    <xsl:value-of select="f:diff(concat($base-path, '/@', name()), 1)"/>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:param name="base-path"/>
    <xsl:variable name="local-name" select="local-name()"/>
    <xsl:variable name="path">
      <xsl:choose>
        <xsl:when test="$strict-pos[. = $local-name or . = '*']"><!-- strict positioning turned on for comparing this element -->
          <xsl:value-of select="concat($base-path, '/', name(), '[', position(), ']')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($base-path, '/', name())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:value-of select="f:diff($path)"/>

    <xsl:if test="$attributes">
      <xsl:apply-templates select="@*">
        <xsl:with-param name="base-path" select="$path"/>
      </xsl:apply-templates>
    </xsl:if>
    
    <xsl:apply-templates select="*">
      <xsl:with-param name="base-path" select="$path"/>
    </xsl:apply-templates>    
  </xsl:template>

  <func:function name="f:diff">
    <xsl:param name="path"/>
    <xsl:param name="isattr"/>

    <xsl:variable name="ref-el" select="dyn:evaluate(concat('$ref', $path))"/>

    <func:result>
      <xsl:choose>
        <xsl:when test="not($ref-el)">error: missing <xsl:value-of select="$path"/><xsl:text>
</xsl:text></xsl:when>
        <xsl:otherwise>
          <xsl:if test="$text-diff and (text() != $ref-el/text() or ($isattr and . != $ref-el))">warning: content <xsl:value-of select="$path"/>:<xsl:text>
</xsl:text> --- <xsl:value-of select="."/><xsl:text>
</xsl:text> +++ <xsl:value-of select="$ref-el"/><xsl:text>
</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>    
</xsl:stylesheet>
