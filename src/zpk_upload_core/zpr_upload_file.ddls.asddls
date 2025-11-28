@EndUserText.label: 'Parameters for Upload File'
define abstract entity zpr_upload_file
  //  with parameters parameter_name : parameter_type
{
  @EndUserText.label: 'Attachment'
  @Semantics.largeObject: { mimeType: 'Mimetype',
                          fileName: 'Filename',
                          contentDispositionPreference: #INLINE }
  Attachment : zde_attachment;

  @EndUserText.label: 'File Type'
  @Semantics.mimeType: true
  Mimetype   : zde_mime_type;

  @EndUserText.label: 'Filename'
  @Semantics.user.createdBy: true
  Filename   : zde_filename;

}
