import { createElement } from '@lwc/engine-dom';
import B2bProductStockIndicator from 'c/b2bProductStockIndicator';

describe('c-b2-b-product-stock-indicator', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('TODO: test case generated by CLI command, please fill in test logic', () => {
        // Arrange
        const element = createElement('c-b2-b-product-stock-indicator', {
            is: B2bProductStockIndicator
        });

        // Act
        document.body.appendChild(element);

        // Assert
        // const div = element.shadowRoot.querySelector('div');
        expect(1).toBe(1);
    });
});