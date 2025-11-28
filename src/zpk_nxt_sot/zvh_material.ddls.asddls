@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Value Help with Description'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}


//define view entity ZVH_MATERIAL
//  as select distinct from I_MaterialDocumentItem_2 as MatDoc
//    left outer join       I_ProductDescription_2   as ProdDesc on  MatDoc.Material   = ProdDesc.Product
//                                                               and ProdDesc.Language = $session.system_language
//{
//      @Search.defaultSearchElement: true
//      @Search.fuzzinessThreshold: 0.8
//  key MatDoc.Material,
//
//      @Search.defaultSearchElement: true
//      @Search.fuzzinessThreshold: 0.7
//      ProdDesc.ProductDescription,
//
//      // Concatenated field for display: ProductDescription (Material)
//      concat_with_space(ProdDesc.ProductDescription,
//                       concat(concat('(', MatDoc.Material), ')'),
//                       1) as MaterialWithDescription
//}

define view entity ZVH_MATERIAL
  as select distinct from I_MaterialDocumentItem_2 as MatDoc
    left outer join       I_ProductDescription_2   as ProdDesc on  MatDoc.Material   = ProdDesc.Product
                                                               and ProdDesc.Language = $session.system_language
{
      @ObjectModel.text.element: ['Material']
            @Search.defaultSearchElement: true

  key MatDoc.Material,

      ProdDesc.ProductDescription
//      
//            concat_with_space(ProdDesc.ProductDescription,
//                       concat(concat('(', MatDoc.Material), ')'),
//                       1) as MaterialWithDescription

//      concat_with_space(
//        ProdDesc.ProductDescription,
//        concat(concat('(', ltrim(MatDoc.Material,'0')), ')'),
//        1
//      ) as MaterialWithDescription
}
