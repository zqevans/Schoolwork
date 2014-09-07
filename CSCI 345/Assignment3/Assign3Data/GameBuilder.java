/**
 * This work is licensed under the Creative Commons Attribution 3.0
 * Unported License. To view a copy of this license, visit
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to
 * Creative Commons, 444 Castro Street, Suite 900,
 * Mountain View, California, 94041, USA. 
 */

package cs345evansz2;

/**
 * This is the interface provided for classes that build games.
 * 
 * @author Chris Reedy (Chris.Reedy@wwu.edu)
 */
public interface GameBuilder {
	
	/**
	 * Build the game. It is assumed that any initialization that
	 * might be required to actually build the game as already
	 * occurred.
	 */
	public void build();

}
