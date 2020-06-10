//
//  FIGMM.swift
//  WoosmapGeofencing
//
//  Created by Mac de Laurent on 26/05/2020.
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation
import Surge
import CoreData


typealias Scalar = Double
public var list_zois: [Dictionary<String, Any>] = []
var list_zois_to_delete: [Dictionary<String, Any>] = []
let age_min = 5.0
let acc_min = 3.0

let chi_squared_value_for_update = chi_squared_value(probability: 0.95);

func chi_squared_value(probability: Double) -> Double{
    return -2 * log(1 - probability)
}

public func figmmForVisit(newVisitPoint:MyPoint) -> [Dictionary<String, Any>]{
  
    // Learning
    let zois_have_been_updated = incrementZOI( point: newVisitPoint)
    
    // Creating new components
    if (!zois_have_been_updated) {
        createInitialCluster(newVisitPoint: newVisitPoint);
    }
    
    // Removing spurious components
    clean_clusters()
    
    // Update prior
    update_zois_prior()
    
    predict_as_dict(visitPoint: newVisitPoint)
    
    trace()
    
    prepareDataForDB()
    
    return list_zois
}

public func setListZOIsFromDB(zoiFromDB:[Dictionary<String, Any>]) {
    list_zois = []
    for zoi in zoiFromDB {
        let covariance_matrix_inverse: Matrix<Scalar> = [
            [zoi["x00Covariance_matrix_inverse"] as! Double, zoi["x01Covariance_matrix_inverse"] as! Double],
            [zoi["x10Covariance_matrix_inverse"] as! Double, zoi["x11Covariance_matrix_inverse"] as! Double],
        ]
        
        var zois_gmm_info = Dictionary<String, Any>()
        zois_gmm_info = zoi
        zois_gmm_info["covariance_matrix_inverse"] = covariance_matrix_inverse
        list_zois.append(zois_gmm_info)
    }
}

func prepareDataForDB(){
    for (index, zois_gmm_info) in list_zois.enumerated() {
        let covariance_matrix_inverse: Matrix<Scalar> = zois_gmm_info["covariance_matrix_inverse"] as! Matrix<Scalar>
        for (idx,element) in covariance_matrix_inverse.enumerated(){
            if(idx == 0){
                list_zois[index]["x00Covariance_matrix_inverse"] = element[0]
                list_zois[index]["x01Covariance_matrix_inverse"] = element[1]
            } else if (idx == 1) {
                list_zois[index]["x10Covariance_matrix_inverse"] = element[2]
                list_zois[index]["x11Covariance_matrix_inverse"] = element[3]
            }
            
        }
        
    }
}

func trace() {
    for (index, _) in list_zois.enumerated() {
        geometryFigmm(zois_gmm_info: &list_zois[index])
    }
}

func update_zois_prior(){
    var normalization_params = 0.0;
    for zois_gmm_info in list_zois {
        normalization_params += zois_gmm_info["accumulator"] as! Double
    }
    
    for (index, zois_gmm_info) in list_zois.enumerated() {
        list_zois[index]["prior_probability"] = (zois_gmm_info["accumulator"] as! Double) / normalization_params
    }
}

func clean_clusters() {
    for zois_gmm_info in list_zois {
        if ((zois_gmm_info["age"] as! Double) > age_min && (zois_gmm_info["accumulator"] as! Double) < acc_min) {
            list_zois_to_delete.append(zois_gmm_info);
        }
    }
}

func createInitialCluster(newVisitPoint:MyPoint) {
    // We use a multiplier because of true visit are not exactly on the position of the point.
    // So we left more variance to create clusters
    let covariance_multiplier = 2.0
    let sigma = newVisitPoint.getAccuray() * covariance_multiplier
    
    let covariance_initial_value = pow(sigma, 2)
    
    var zois_gmm_info = Dictionary<String, Any>()
    typealias Scalar = Double
    
    let covariance_matrix_inverse: Matrix<Scalar> = [
        [1.0, 0.0],
        [0.0, 1.0],
    ]
    
    zois_gmm_info["covariance_matrix_inverse"] = Surge.mul(pow(sigma, -2),covariance_matrix_inverse)
    
    zois_gmm_info["mean"] = [newVisitPoint.getX(), newVisitPoint.getY()]
    
    if (list_zois.isEmpty) {
        zois_gmm_info["prior_probability"] = 1.0
    } else {
        var accumulator_sum = 1.0;
        for gmm_info in list_zois {
            accumulator_sum +=  gmm_info["accumulator"] as! Double;
        }
        zois_gmm_info["prior_probability"] = 1/accumulator_sum
    }
    
    zois_gmm_info["age"] = 1.0
    zois_gmm_info["accumulator"] = 1.0
    zois_gmm_info["updated"] = true
    zois_gmm_info["covariance_det"] = pow(covariance_initial_value, 2)
    zois_gmm_info["idVisits"] = []
    zois_gmm_info["startTime"] = newVisitPoint.startTime
    zois_gmm_info["endTime"] = newVisitPoint.endTime
    
    
    list_zois.append(zois_gmm_info);
}

//predict cluster for each data and return them as dict to optimized insertion
func predict_as_dict(visitPoint: MyPoint) {
    typealias Scalar = Double
    var cov_determinants: [Double] = []
    var prior_probabilities: [Double] = []
    var sqr_mahalanobis_distances: [Double] = []
    
    for zois_gmm_info in list_zois {
        cov_determinants.append(zois_gmm_info["covariance_det"] as! Double)
        prior_probabilities.append(zois_gmm_info["prior_probability"] as! Double)
        let point_matrix: Matrix<Scalar> = [
            [visitPoint.getX(), visitPoint.getY()]
        ]
        let x_mean = (zois_gmm_info["mean"] as! Array<Any>)[0] as! Double
        let y_mean = (zois_gmm_info["mean"] as! Array<Any>)[1] as! Double
        
        let mean_matrix: Matrix<Scalar> = [
            [x_mean,y_mean]
        ]
        
        let matrix_error = point_matrix - mean_matrix
        let covariance_matrix_inverse: Matrix<Scalar> = zois_gmm_info["covariance_matrix_inverse"] as! Matrix<Scalar>
        let a = matrix_error * covariance_matrix_inverse
        let a2 = a * transpose(matrix_error)

        let mahalanobis_distance = sqrt(a2[0][0])

        sqr_mahalanobis_distances.append(pow(mahalanobis_distance,2))
        
    }
    
    // We calculate all values at once using matrix calculations
    let x_j_probabilities = getProbabilityOfXKnowingCluster(cov_determinants: cov_determinants, sqr_mahalanobis_distances: sqr_mahalanobis_distances)
    
    var result_x_j_prob_prior_prob_Array: [Double] = []
    
    for (index, x_j_probabilitie) in x_j_probabilities.enumerated() {
        result_x_j_prob_prior_prob_Array.append(x_j_probabilitie*prior_probabilities[index])
    }
    
    let indexMaxProbPrior = result_x_j_prob_prior_prob_Array.firstIndex(of: max(result_x_j_prob_prior_prob_Array))
    
    var idVisitsArray:[UUID] =  list_zois[indexMaxProbPrior!]["idVisits"] as! [UUID]
    idVisitsArray.append(visitPoint.getId())
    list_zois[indexMaxProbPrior!]["idVisits"] = idVisitsArray
   
    
}


func incrementZOI(point:MyPoint) -> Bool {
    typealias Scalar = Double
    var zois_have_been_updated = false
    var cov_determinants: [Double] = []
    var prior_probabilities: [Double] = []
    var sqr_mahalanobis_distances: [Double] = []
    
    for zois_gmm_info in list_zois {
        cov_determinants.append(zois_gmm_info["covariance_det"] as! Double)
        prior_probabilities.append(zois_gmm_info["prior_probability"] as! Double)
        
        
        let point_matrix: Matrix<Scalar> = [
            [point.getX(), point.getY()]
        ]
        
        let x_mean = (zois_gmm_info["mean"] as! Array<Any>)[0] as! Double
        let y_mean = (zois_gmm_info["mean"] as! Array<Any>)[1] as! Double
        
        let mean_matrix: Matrix<Scalar> = [
            [x_mean,y_mean]
        ]
        
        let matrix_error = point_matrix - mean_matrix
        let covariance_matrix_inverse: Matrix<Scalar> = zois_gmm_info["covariance_matrix_inverse"] as! Matrix<Scalar>
        let a = matrix_error * covariance_matrix_inverse
        let a2 = a * transpose(matrix_error)
        
        let mahalanobis_distance = sqrt(a2[0][0])
        
        sqr_mahalanobis_distances.append(pow(mahalanobis_distance,2))
        
    }
    
    // We calculate all values at once using matrix calculations
    let x_j_probabilities = getProbabilityOfXKnowingCluster(cov_determinants: cov_determinants, sqr_mahalanobis_distances: sqr_mahalanobis_distances)
    
    var result_x_j_prob_prior_prob_Array: [Double] = []
    
    for (index, x_j_probabilitie) in x_j_probabilities.enumerated() {
        result_x_j_prob_prior_prob_Array.append(x_j_probabilitie*prior_probabilities[index])
    }
    
    let normalization_coefficient = result_x_j_prob_prior_prob_Array.reduce(0, +)
    
    for (index, _) in list_zois.enumerated() {
        if (sqr_mahalanobis_distances[index] <= chi_squared_value_for_update) {
            updateCluster(point: point, x_j_probability: x_j_probabilities[index], zoi_gmminfo: &list_zois[index], normalization_coefficient: normalization_coefficient);
            zois_have_been_updated = true;
        }
    }
    
    return zois_have_been_updated
}

func updateCluster(point: MyPoint, x_j_probability: Double, zoi_gmminfo: inout Dictionary<String, Any>, normalization_coefficient: Double) {
    let j_x_probability = x_j_probability * ((zoi_gmminfo["prior_probability"] as! Double) / normalization_coefficient )
    zoi_gmminfo["age"] = zoi_gmminfo["age"] as! Double + 1
    zoi_gmminfo["accumulator"] = zoi_gmminfo["accumulator"] as! Double + j_x_probability
    
    typealias Scalar = Double
    
    let point_matrix: Matrix<Scalar> = [
        [point.getX(), point.getY()]
    ]
    
    let x_mean = (zoi_gmminfo["mean"] as! Array<Any>)[0] as! Double
    let y_mean = (zoi_gmminfo["mean"] as! Array<Any>)[1] as! Double
    
    let mean_matrix: Matrix<Scalar> = [
        [x_mean,y_mean]
    ]
    
    let error_matrix = point_matrix - mean_matrix
    let weight = j_x_probability / (zoi_gmminfo["accumulator"] as! Double)
    let delta_mean_matrix = Surge.mul(weight,error_matrix)
    let mean_plus_delta_mean_matrix = delta_mean_matrix + mean_matrix
    let covariance_matrix_inverse: Matrix<Scalar> = zoi_gmminfo["covariance_matrix_inverse"] as! Matrix<Scalar>
    let new_error_matrix = point_matrix - mean_plus_delta_mean_matrix
    
    let factorTerm1 = weight / pow(1 - weight, 2)
    let new_term1 = Surge.mul(factorTerm1, covariance_matrix_inverse * transpose(new_error_matrix) * new_error_matrix * covariance_matrix_inverse)
    
    let factorTerm2 = weight / (1 - weight)
    let new_term2 = Surge.mul(factorTerm2,new_error_matrix * covariance_matrix_inverse * transpose(new_error_matrix))[0] + 1
    
    let cov_inv_delta = covariance_matrix_inverse / (1 - weight) - (new_term1 / new_term2[0])
    
    let term3 = cov_inv_delta * transpose(delta_mean_matrix) * delta_mean_matrix * cov_inv_delta
    let term4a = delta_mean_matrix * cov_inv_delta * transpose(delta_mean_matrix)
    let term4 = 1 - term4a[0][0]
    let new_inv_matrix = cov_inv_delta + term3 / term4
    
    let cov_det_delta1 = pow((1 - weight), 2) * (zoi_gmminfo["covariance_det"] as! Double)
    let cov_det_delta2 = new_error_matrix * cov_inv_delta * transpose(new_error_matrix)
    let cov_det_delta3 = Surge.mul((weight / (1 - weight)),cov_det_delta2)[0][0] + 1
    let cov_det_delta  = cov_det_delta1 * cov_det_delta3
    
    let new_covariance_determinant = (1 - (delta_mean_matrix * cov_inv_delta * transpose(delta_mean_matrix))[0][0]) * cov_det_delta
    
    zoi_gmminfo["mean"] = [mean_plus_delta_mean_matrix[0][0], mean_plus_delta_mean_matrix[0][1]]
    
    if (new_covariance_determinant > 0) {
        zoi_gmminfo["covariance_matrix_inverse"] = new_inv_matrix
        zoi_gmminfo["covariance_det"] = new_covariance_determinant
    }
    
}

func getProbabilityOfXKnowingCluster(cov_determinants: [Double], sqr_mahalanobis_distances: [Double]) -> [Double] {
    
    let exp_mahalanobis_distances = sqr_mahalanobis_distances.map{ exp(-1*$0/2) }
    let sqrt_cov_determinants = cov_determinants.map{ sqrt($0) * 2 * Double.pi }
    
    var probability_of_x_knowing_cluster:[Double] = []
    
    for (index, exp_mahalanobis_distance) in exp_mahalanobis_distances.enumerated() {
        probability_of_x_knowing_cluster.append(exp_mahalanobis_distance/sqrt_cov_determinants[index])
    }
    
    return probability_of_x_knowing_cluster
}


func geometryFigmm(zois_gmm_info:inout Dictionary<String, Any>){
    typealias Scalar = Double
    
    let covariance_matrix_inverse: Matrix<Scalar> = zois_gmm_info["covariance_matrix_inverse"] as! Matrix<Scalar>
    
    let cov_inv = inv(covariance_matrix_inverse)
    
    let ed = try! eigenDecompose(cov_inv)
    
    
    let flatLeft = ed.leftEigenVectors.flatMap { $0 }
    let flatRight = ed.rightEigenVectors.flatMap { $0 }
    
    var vectorWithMaxValue = [Double]()
    if(Double(ed.eigenValues.first!.0) > Double(ed.eigenValues.last!.0)){
        vectorWithMaxValue.append(flatLeft[0].0)
        vectorWithMaxValue.append(flatLeft[2].0)
    } else {
        vectorWithMaxValue.append(flatRight[1].0)
        vectorWithMaxValue.append(flatRight[3].0)
    }
    
    let A_norm = sqrt(pow(vectorWithMaxValue[0], 2) + pow(vectorWithMaxValue[1], 2))
    
    let cos_theta = vectorWithMaxValue[0]/A_norm
    let sin_theta = vectorWithMaxValue[1]/A_norm
    
    
    let a_vector: Matrix<Scalar> = [[cos_theta, sin_theta]]
    let b_vector: Matrix<Scalar> = [[-sin_theta, cos_theta]]
    
    let x_mean = (zois_gmm_info["mean"] as! Array<Any>)[0] as! Double
    let y_mean = (zois_gmm_info["mean"] as! Array<Any>)[1] as! Double
    
    let a = (a_vector * covariance_matrix_inverse * transpose(a_vector))
    let a_val = sqrt(chi_squared_value(probability: 0.7)/a[0][0])
    
    let b = (b_vector * covariance_matrix_inverse * transpose(b_vector))
    let b_val = sqrt(chi_squared_value(probability: 0.7)/b[0][0])
    
    var wktPolygon = "POLYGON(("
    let step = 8.0
    let valLimit = Int(2 * Double.pi * step) + 1;
    
    let sMercator = SphericalMercator()
    var firstCoord = ""
    for i in 0...valLimit {
        
        let t = Double(i) / step
        let cos_t = cos(Double(t))
        let sin_t = sin(Double(t))
        let x = x_mean + a_val * cos_theta * cos_t - b_val * sin_theta * sin_t
        let y = y_mean + a_val * sin_theta * cos_t + b_val * cos_theta * sin_t
        
        let latitude = String(format:"%f",sMercator.x2lon(aX: x))
        let longitude = String(format:"%f",sMercator.y2lat(aY: y))
        wktPolygon.append(latitude)
        wktPolygon.append(" ")
        wktPolygon.append(longitude)
        wktPolygon.append(",");
        
        if(i == 0)
        {
            firstCoord.append(String(format:"%f",sMercator.x2lon(aX: x)))
            firstCoord.append(" ")
            firstCoord.append(String(format:"%f",sMercator.y2lat(aY: y)))
            firstCoord.append("))");
        }
        
    }
    wktPolygon.append(firstCoord)
    
    zois_gmm_info["WktPolygon"] = wktPolygon
}

public class MyPoint {
    
    var x: Double
    var y: Double
    var accuracy: Double
    var id: UUID
    var startTime: Date?
    var endTime: Date?
    
    init(){
        self.x = 0
        self.y = 0
        self.id = UUID()
        self.accuracy = 20.0
        self.startTime = Date()
        self.endTime = Date()
    }
    
    init(x:Double, y:Double, id:UUID) {
        self.x = x
        self.y = y
        self.id = id
        self.accuracy = 20.0
        self.startTime = Date()
        self.endTime = Date()
    }
    
    public init(x:Double, y:Double, accuracy:Double, id:UUID, startTime:Date, endTime:Date) {
        self.x = x
        self.y = y
        self.id = id
        self.accuracy = accuracy
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public func getX() -> Double {
        return x
    }
    
    func getY() -> Double {
        return y
    }
    
    func getAccuray() -> Double {
        return accuracy
    }
    
    func getId() -> UUID {
        return id
    }
    
}

public class SphericalMercator {
    private let radius: Double = 6378137.0; /* in meters on the equator */
    
    /* These functions take their length parameter in meters and return an angle in degrees */
    
    public init(){}
    
    public func y2lat(aY: Double) -> Double {
        (atan(exp(aY / radius)) * 2 - Double.pi/2).radiansToDegrees
    }
    
    public func x2lon(aX: Double) -> Double {
        (aX / radius).radiansToDegrees;
    }
    
    /* These functions take their angle parameter in degrees and return a length in meters */
    
    public func lat2y(aLat: Double) -> Double {
        log(tan(Double.pi / 4 + (aLat.degreesToRadians / 2))) * radius
    }
    
    public func lon2x(aLong: Double) -> Double {
        (aLong).degreesToRadians * radius;
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

